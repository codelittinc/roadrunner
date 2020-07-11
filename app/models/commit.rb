class Commit < ApplicationRecord
  belongs_to :pull_request

  validates :sha, presence: true
  validates :author_name, presence: true
  validates :author_email, presence: true
end
