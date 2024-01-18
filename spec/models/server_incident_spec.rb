# frozen_string_literal: true

# == Schema Information
#
# Table name: server_incidents
#
#  id                     :bigint           not null, primary key
#  message                :string
#  state                  :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  application_id         :integer
#  server_status_check_id :bigint
#  slack_message_id       :bigint
#
# Indexes
#
#  index_server_incidents_on_server_status_check_id  (server_status_check_id)
#  index_server_incidents_on_slack_message_id        (slack_message_id)
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
