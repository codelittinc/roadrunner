class Repository < ApplicationRecord
  has_many :servers
  has_one :slack_repository_info
end
