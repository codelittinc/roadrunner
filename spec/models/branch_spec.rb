# frozen_string_literal: true

# == Schema Information
#
# Table name: branches
#
#  id              :bigint           not null, primary key
#  name            :string
#  repository_id   :bigint           not null
#  pull_request_id :bigint
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
require 'rails_helper'

RSpec.describe Branch, type: :model do
  describe 'should validate the props' do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe 'associations' do
    it { should belong_to(:repository) }
  end
end
