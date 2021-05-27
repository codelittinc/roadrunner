# frozen_string_literal: true

class ChangelogsService
  LINK_REGEX = %r{https?[a-zA-Z/:\-_.0-9]*}
  JIRA_REFERENCE_REGEX = /[a-zA-Z]+-\d+/
  AZURE_AND_GITHUB_REFERENCE_REGEX = /\d+$/
  JIRA_TYPE = 'jira'
  AZURE_TYPE = 'azure'
  GITHUB_TYPE = 'github'

  def initialize(release, commits)
    @release = release
    @commits = commits
  end

  def changelog
    {
      version: @release.version,
      id: @release.id,
      created_at: @release.created_at,
      changes: self.class.changes(@commits)
    }
  end

  def self.changes(commits)
    commits.uniq.map do |commit|
      {
        message: commit.message,
        references: {
          task_manager: urls_from_description(commit.pull_request.description)
        }
      }
    end
  end

  def self.urls_from_description(description)
    description
      .scan(LINK_REGEX)
      .select { |url| [JIRA_TYPE, AZURE_TYPE, GITHUB_TYPE].include? url_type(url) }
      .map do |url|
        {
          link: url,
          type: url_type(url),
          reference_code: url_reference(url)
        }
      end
  end

  def self.url_type(url)
    case url
    when /.+atlassian.+/
      JIRA_TYPE
    when /.+azure.+/
      AZURE_TYPE
    when /^(?=.*\bgithub\b)(?=.*\bissues\b).*$/
      GITHUB_TYPE
    else
      'unknown'
    end
  end

  def self.url_reference(url)
    url_type(url) == JIRA_TYPE ? url[JIRA_REFERENCE_REGEX] : url[AZURE_AND_GITHUB_REFERENCE_REGEX]
  end
end
