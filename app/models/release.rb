# frozen_string_literal: true

class Release < ApplicationRecord
  belongs_to :application
  validates :version, presence: true
end
