class ServerStatusCheck < ApplicationRecord
  belongs_to :server

  def incident_type
    'status_verification'
  end
end
