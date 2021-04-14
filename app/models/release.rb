# frozen_string_literal: true

class Release < ApplicationRecord
  belongs_to :application
  has_many :commit_releases, dependent: :destroy
  has_many :commits, through: :commit_releases

  validates :version, presence: true
end
