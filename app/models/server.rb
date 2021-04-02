# frozen_string_literal: true

# == Schema Information
#
# Table name: servers
#
#  id                    :bigint           not null, primary key
#  link                  :string
#  supports_health_check :boolean
#  repository_id         :bigint
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  external_identifier   :string
#  active                :boolean          default(TRUE)
#
class Server < ApplicationRecord
  belongs_to :application

  validates :link, presence: true
  validates :application, presence: true

  has_one :repository, through: :application
  has_one :slack_repository_info, through: :repository
  has_many :server_incidents
  has_many :server_status_checks

  VALID_STATUS_CODES = [401, 200].freeze

  def status
    @status ||= compute_status
  end

  private

  def compute_status
    health_checks ||= server_status_checks.where(created_at: status_interval).length.positive?

    return 'data unavailable' unless health_checks

    incidents ||= server_incidents.where(created_at: status_interval).length.positive?
    if health_checks
      return 'unavailable' unless VALID_STATUS_CODES.include?(server_status_checks.last.code)

      return incidents ? 'unstable' : 'normal'
    end

    nil
  end

  def status_interval
    before = Time.zone.now - 1.hour
    before..Time.zone.now
  end
end
