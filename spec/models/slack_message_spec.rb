# == Schema Information
#
# Table name: slack_messages
#
#  id              :bigint           not null, primary key
#  ts              :string
#  pull_request_id :bigint
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  text            :string
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
