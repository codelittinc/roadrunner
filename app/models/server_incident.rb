# == Schema Information
#
# Table name: server_incidents
#
#  id                     :bigint           not null, primary key
#  message                :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  server_id              :bigint
#  server_status_check_id :bigint
#
# Indexes
#
#  index_server_incidents_on_server_id               (server_id)
#  index_server_incidents_on_server_status_check_id  (server_status_check_id)
#
class ServerIncident < ApplicationRecord
  belongs_to :server
  belongs_to :server_status_check, optional: true

  INCIDENT_ERROR = 'error'.freeze
  INCIDENT_WARNING = 'warning'.freeze

  def incident_type
    server_status_check ? INCIDENT_ERROR : INCIDENT_WARNING
  end
end
