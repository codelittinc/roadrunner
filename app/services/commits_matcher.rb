# frozen_string_literal: true

class CommitsMatcher
  def initialize(github_commits)
    @github_commits = github_commits
  end

  def commits
    commits = []
    @github_commits.each do |commit|
      message = commit[:commit][:message]
      c = Commit.order(created_at: :desc)
                .where.not(id: commits&.map(&:id))
                .where(message: message).first

      commits << c if c
    end

    commits.sort_by(&:created_at)
  end
end
