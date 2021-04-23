# frozen_string_literal: true

class ChangelogsService
  LINK_REGEX = %r{https?[a-zA-Z/:\-.0-9]*}

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
      .select { |url| url_type(url) == 'jira' }
      .map do |url|
        {
          link: url,
          type: url_type(url),
          reference_code: url_reference(url)
        }
      end
  end

  def self.url_type(url)
    url.match?(/.+atlassian.+/) ? 'jira' : 'unknown'
  end

  def self.url_reference(url)
    url[/[a-zA-Z]+-\d+/]
  end
end
