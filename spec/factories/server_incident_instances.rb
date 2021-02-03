# frozen_string_literal: true

# == Schema Information
#
# Table name: server_incident_instances
#
#  id                 :bigint           not null, primary key
#  server_incident_id :bigint           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
FactoryBot.define do
  factory :server_incident_instance do
  end
end
