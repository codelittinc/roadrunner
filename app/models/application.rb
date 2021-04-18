# frozen_string_literal: true

# == Schema Information
#
# Table name: applications
#
#  id                  :bigint           not null, primary key
#  environment         :string
#  external_identifier :string
#  repository_id       :bigint           not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
class Application < ApplicationRecord
  belongs_to :repository

  has_one :server, dependent: :destroy
  has_many :server_incidents, dependent: :destroy
  has_many :releases, dependent: :destroy

  DEV = 'dev'
  QA = 'qa'
  PROD = 'prod'

  validates :environment, presence: true, inclusion: { in: [DEV, QA, PROD] }
  validates :external_identifier, presence: true, uniqueness: true

  def latest_release
    releases.last
  end
end
