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
require 'rails_helper'

RSpec.describe ServerIncidentInstance, type: :model do
  describe 'associations' do
    it { should belong_to(:server_incident) }
  end
end
