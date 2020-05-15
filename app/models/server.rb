class Server < ApplicationRecord
  belongs_to :repository

  validates :link, presence: true
  validates :repository, presence: true
end
