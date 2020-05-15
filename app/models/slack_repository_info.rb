class SlackRepositoryInfo < ApplicationRecord
  belongs_to :repository

  validates :deploy_channel, presence: true
  validates :repository, presence: true
end
