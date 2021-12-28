# frozen_string_literal: true

# == Schema Information
#
# Table name: applications
#
#  id            :bigint           not null, primary key
#  environment   :string
#  repository_id :bigint           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class Application < ApplicationRecord
  belongs_to :repository

  has_one :server, dependent: :destroy
  has_many :server_incidents, dependent: :destroy
  has_many :releases, dependent: :destroy
  has_many :external_identifiers, dependent: :destroy

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
end
