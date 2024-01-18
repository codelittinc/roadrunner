# frozen_string_literal: true

# == Schema Information
#
# Table name: servers
#
#  id                    :bigint           not null, primary key
#  active                :boolean          default(TRUE)
#  environment           :string
#  link                  :string
#  supports_health_check :boolean
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  application_id        :bigint
#
# Indexes
#
#  index_servers_on_application_id  (application_id)
#
# Foreign Keys
#
#  fk_rails_...  (application_id => applications.id)
#
class Server < ApplicationRecord
  belongs_to :application

  validates :link, presence: true

  has_many :server_incidents, through: :application
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
    before = 1.hour.ago
    before..Time.zone.now
  end
end
