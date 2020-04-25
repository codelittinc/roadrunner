class User < ApplicationRecord
  validates :slack, presence: true
end
