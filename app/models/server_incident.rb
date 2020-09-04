# frozen_string_literal: true

# == Schema Information
#
# Table name: server_incidents
#
#  id                     :bigint           not null, primary key
#  message                :string
#  server_id              :bigint
#  server_status_check_id :bigint
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
class ServerIncident < ApplicationRecord
  belongs_to :server
  belongs_to :server_status_check, optional: true

  INCIDENT_ERROR = 'error'
  INCIDENT_WARNING = 'warning'

  def incident_type
    server_status_check ? INCIDENT_ERROR : INCIDENT_WARNING
  end
end
