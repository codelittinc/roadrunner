# frozen_string_literal: true

# == Schema Information
#
# Table name: server_incident_instances
#
#  id                 :bigint           not null, primary key
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  server_incident_id :bigint           not null
#
# Indexes
#
#  index_server_incident_instances_on_server_incident_id  (server_incident_id)
#
# Foreign Keys
#
#  fk_rails_...  (server_incident_id => server_incidents.id)
#
class ServerIncidentInstance < ApplicationRecord
  belongs_to :server_incident
end
