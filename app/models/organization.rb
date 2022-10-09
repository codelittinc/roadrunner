# frozen_string_literal: true

class Organization < ApplicationRecord
  validates :notifications_id, presence: true
  validates :name, presence: true
  validates :notifications_key, presence: true
end
