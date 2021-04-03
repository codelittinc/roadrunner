# frozen_string_literal: true

class CommitsMatcher
  def initialize(github_commits)
    @github_commits = github_commits
  end

  def commits
    @github_commits.map do |commit|
      date = commit[:commit][:committer][:date]
      before = date - 15.days
      after = date + 15.days

      message = commit[:commit][:message]

      Commit.find_by(created_at: before..after, message: message)
    end.flatten
  end
end
