class Repository < ApplicationRecord
  belongs_to :project
  has_many :servers
  has_one :slack_repository_info
end
