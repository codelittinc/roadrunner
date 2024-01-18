# frozen_string_literal: true

# == Schema Information
#
# Table name: applications
#
#  id            :bigint           not null, primary key
#  environment   :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  repository_id :bigint           not null
#
# Indexes
#
#  index_applications_on_repository_id  (repository_id)
#
# Foreign Keys
#
#  fk_rails_...  (repository_id => repositories.id)
#
class Application < ApplicationRecord
  belongs_to :repository

  has_one :server, dependent: :destroy
  has_many :server_incidents, dependent: :destroy
  has_many :releases, dependent: :destroy
  has_many :external_identifiers, dependent: :destroy

  accepts_nested_attributes_for :server, allow_destroy: true
  accepts_nested_attributes_for :external_identifiers, allow_destroy: true

  DEV = 'dev'
  QA = 'qa'
  UAT = 'uat'
  PROD = 'prod'

  validates :environment, presence: true, inclusion: { in: [DEV, QA, UAT, PROD] }

  def self.by_external_identifier(*external_identifiers)
    cleaned_identifiers = external_identifiers.flatten.compact.map(&:downcase)
    ExternalIdentifier.all.find do |identifier|
      cleaned_identifiers.include?(identifier.text.downcase)
    end&.application
  end

  def latest_release
    releases.last
  end

  scope :with_server, -> { joins(:server) }
end
