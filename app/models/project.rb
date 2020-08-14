class Project < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :repositories
end
