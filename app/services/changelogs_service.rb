# frozen_string_literal: true

class ChangelogsService
  LINK_REGEX = %r{https?[a-zA-Z/:\-.0-9]*}

  def initialize(commits, version)
    @commits = commits
    @version = version
  end

  def changelog
    {
      version: @version,
      changes: changes
    }
  end

  private

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

  def changes
    @commits.map(&:pull_request).uniq.map do |pull_request|
      {
        message: pull_request.title,
        references: urls_from_description(pull_request.description)
      }
    end
  end
end
