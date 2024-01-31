# frozen_string_literal: true

class CommitsMatcher
  def initialize(source_control_commits, repository)
    @source_control_commits = source_control_commits
    @repository = repository
  end

  def commits
    commits_list = []
    @source_control_commits.each do |commit|
      message = commit.message[0..50]

      change = Commit.by_repository(@repository)
                     .order(created_at: :desc)
                     .where.not(id: commits_list&.map(&:id))
                     .where('message LIKE ?', "%#{message}%").first

      commits_list << change if change
    end

    commits_list.sort_by(&:created_at)
  end
end
