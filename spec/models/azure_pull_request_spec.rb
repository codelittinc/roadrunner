# frozen_string_literal: true

# == Schema Information
#
# Table name: azure_pull_requests
#
#  id              :bigint           not null, primary key
#  azure_id        :string
#  pull_request_id :bigint
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
require 'rails_helper'

RSpec.describe AzurePullRequest, type: :model do
  describe 'associations' do
    it { should have_one(:pull_request) }
  end

  describe 'validations' do
    it { should validate_presence_of(:azure_id) }
    it { should validate_presence_of(:pull_request) }
  end
end
