# frozen_string_literal: true

class ChangelogsService
  def initialize(application)
    @application = application
  end

  def changelog
    {
      version: @application.latest_release.version,
      changes: commits_data
    }
  end

  private

  # rubocop:disable Style/RedundantRegexpEscape, Style/RegexpLiteral
  LINK_REGEX = /https?[a-zA-Z\/:\-\.0-9]*/
  # rubocop:enable Style/RedundantRegexpEscape, Style/RegexpLiteral

  def urls_from_description(description)
    description.scan(LINK_REGEX).map do |url|
      {
        link: url,
        type: url_type(url)
      }
    end
  end

  def url_type(url)
    url.match?(/.+atlassian.+/) ? 'jira' : 'unknown'
  end

  def commits_data
    commits = @application.latest_release.commits
    commits.map do |commit|
      {
        message: commit.message,
        references: urls_from_description(commit.pull_request.description)
      }
    end
  end
end
