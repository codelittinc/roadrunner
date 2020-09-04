# frozen_string_literal: true

# == Schema Information
#
# Table name: pull_request_reviews
#
#  id              :bigint           not null, primary key
#  state           :string
#  username        :string
#  pull_request_id :bigint           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
require 'rails_helper'

RSpec.describe PullRequestReview, type: :model do
  describe 'associations' do
    it { should belong_to(:pull_request) }
  end

  describe 'should validate the props' do
    it { is_expected.to validate_presence_of(:state) }
    it { is_expected.to validate_presence_of(:username) }
  end
end
