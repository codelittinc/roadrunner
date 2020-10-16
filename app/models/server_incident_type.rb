# frozen_string_literal: true

# == Schema Information
#
# Table name: server_incident_types
#
#  id               :bigint           not null, primary key
#  name             :string
#  regex_identifier :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class ServerIncidentType < ApplicationRecord
  validates :name, presence: true
  validates :regex_identifier, presence: true
end
