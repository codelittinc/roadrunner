class ServerIncident < ApplicationRecord
  belongs_to :server
  belongs_to :server_status_check, optional: true

  INCIDENT_ERROR = 'error'
  INCIDENT_WARNING = 'warning'

  def incident_type
    server_status_check ? INCIDENT_ERROR : INCIDENT_WARNING
  end
end
