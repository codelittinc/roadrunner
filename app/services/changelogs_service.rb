# frozen_string_literal: true

class ChangelogsService
  LINK_REGEX = %r{https?[a-zA-Z/:\-_.0-9]*}
  JIRA_REFERENCE_REGEX = /[a-zA-Z]+-\d+/
  AZURE_AND_GITHUB_REFERENCE_REGEX = %r{(\d+)/?$}
  TRELLO_REFERENCE_REGEX = %r{[a-zA-Z\-0-9]*/?$}
  JIRA_TYPE = 'jira'
  AZURE_TYPE = 'azure'
  GITHUB_TYPE = 'github'
  TRELLO_TYPE = 'trello'

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
      &.scan(LINK_REGEX)
      &.select { |url| [JIRA_TYPE, AZURE_TYPE, GITHUB_TYPE, TRELLO_TYPE].include? url_type(url) }
      &.map do |url|
        {
          link: url,
          type: url_type(url),
          reference_code: url_reference(url)
        }
      end || []
  end

  def self.url_type(url)
    case url
    when /.+atlassian.+/
      JIRA_TYPE
    when /.+azure.+/
      AZURE_TYPE
    when /^(?=.*\bgithub\b)(?=.*\bissues\b).*$/
      GITHUB_TYPE
    when /.+trello.+/
      TRELLO_TYPE
    else
      'unknown'
    end
  end

  def self.reference_regex(type)
    case type
    when GITHUB_TYPE, AZURE_TYPE
      AZURE_AND_GITHUB_REFERENCE_REGEX
    when JIRA_TYPE
      JIRA_REFERENCE_REGEX
    when TRELLO_TYPE
      TRELLO_REFERENCE_REGEX
    end
  end

  def self.url_reference(url)
    regex = reference_regex(url_type(url))
    possible_match = url[regex]

    possible_match&.gsub('/', '')
  end
end
