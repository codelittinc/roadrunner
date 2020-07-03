class PullRequest < ApplicationRecord
  validates :head, presence: true
  validates :base, presence: true

  validates :github_id, presence: true
  validates :title, presence: true
  validates :state, presence: true
  validates :owner, presence: true
end
