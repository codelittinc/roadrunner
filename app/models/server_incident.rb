class ServerIncident < ApplicationRecord
  belongs_to :server
  belongs_to :server_status_check, optional: true
end
