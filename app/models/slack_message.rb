class SlackMessage < ApplicationRecord
  belongs_to :pull_request, optional: true
  validates :ts, presence: true
end
