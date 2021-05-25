# frozen_string_literal: true

class ChangelogsService
  LINK_REGEX = %r{https?[a-zA-Z/:\-_.0-9]*}
  JIRA_REFERENCE_REGEX = /[a-zA-Z]+-\d+/
  AZURE_REFERENCE_REGEX = /\d+$/

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
      .select { |url| url_type(url) == 'jira' || url_type(url) == 'azure' }
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
      'jira'
    when /.+azure.+/
      'azure'
    else
      'unknown'
    end
  end

  def self.url_reference(url)
    url_type(url) == 'jira' ? url[JIRA_REFERENCE_REGEX] : url[AZURE_REFERENCE_REGEX]
  end
end
