# frozen_string_literal: true

# == Schema Information
#
# Table name: slack_messages
#
#  id              :bigint           not null, primary key
#  text            :string
#  ts              :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  pull_request_id :bigint
#
# Indexes
#
#  index_slack_messages_on_pull_request_id  (pull_request_id)
#
require 'rails_helper'

RSpec.describe SlackMessage, type: :model do
  describe 'associations' do
    it { should belong_to(:pull_request).optional }
  end

  describe 'validations' do
    it { should validate_presence_of(:ts) }
  end
end
