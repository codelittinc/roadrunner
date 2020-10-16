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
FactoryBot.define do
  factory :server_incident_type do
    name { 'All' }
    regex_identifier { '/.*/' }
  end
end
