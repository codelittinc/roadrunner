class SlackRepositoryInfo < ApplicationRecord
  belongs_to :repository

  validates :repository, presence: true
end
