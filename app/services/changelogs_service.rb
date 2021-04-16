# frozen_string_literal: true

class ChangelogsService
  def initialize(application)
    @application = application
  end

  def commits_data
    commits = @application.latest_release.commits
    commits.map do |commit|
      { message: commit.message }
    end
  end

  def changelog
    {
      version: @application.latest_release.version,
      changes: commits_data
    }
  end
end
