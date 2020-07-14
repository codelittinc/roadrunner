class SlackMessage < ApplicationRecord
  belongs_to :pull_request
  validates :ts, presence: true
end
