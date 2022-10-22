# frozen_string_literal: true

class Organization < ApplicationRecord
  has_many :github_installations, dependent: :destroy

  validates :notifications_id, presence: true
  validates :name, presence: true
  validates :notifications_key, presence: true
end
