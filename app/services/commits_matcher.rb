# frozen_string_literal: true

class CommitsMatcher
  # @TODO Receive project
  # @TODO Do not use message as a unique key to get commits
  def initialize(github_commits)
    @github_commits = github_commits
  end

  def commits
    commits = []
    @github_commits.each do |commit|
      message = commit.message
      c = Commit.order(created_at: :desc)
                .where.not(id: commits&.map(&:id))
                .where(message:).first

      commits << c if c
    end

    commits.sort_by(&:created_at)
  end
end
