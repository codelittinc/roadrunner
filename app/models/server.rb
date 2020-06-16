class Server < ApplicationRecord
  belongs_to :repository

  validates :link, presence: true
  validates :repository, presence: true

  has_one :slack_repository_info, through: :repository
  has_many :server_incidents
  has_many :server_status_checks
end
