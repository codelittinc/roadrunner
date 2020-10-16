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
require 'rails_helper'

RSpec.describe ServerIncidentType, type: :model do
  describe 'should validate the props' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:regex_identifier) }
  end
end
