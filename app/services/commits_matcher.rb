# frozen_string_literal: true

class CommitsMatcher
  # @TODO Receive project
  # @TODO Do not use message as a unique key to get commits
  def initialize(source_control_commits)
    @source_control_commits = source_control_commits
  end

  def commits
    commits_list = []
    @source_control_commits.each do |commit|
      message = commit.message[0..50]
      change = Commit.order(created_at: :desc).where.not(id: commits_list&.map(&:id)).where('message LIKE ?', "%#{message}%").first

      commits_list << change if change
    end

    commits_list.sort_by(&:created_at)
  end
end
