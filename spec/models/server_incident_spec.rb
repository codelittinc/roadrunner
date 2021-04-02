# frozen_string_literal: true

# == Schema Information
#
# Table name: server_incidents
#
#  id                     :bigint           not null, primary key
#  message                :string
#  server_status_check_id :bigint
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  state                  :string
#  slack_message_id       :bigint
#  application_id         :integer
#
require 'rails_helper'

RSpec.describe ServerIncident, type: :model do
  describe 'should validate the props' do
    it { is_expected.to validate_presence_of(:state) }
  end

  describe 'associations' do
    it { should belong_to(:application) }
    it { should belong_to(:server_status_check).optional }
  end
end
