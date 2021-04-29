# frozen_string_literal: true

# == Schema Information
#
# Table name: github_pull_requests
#
#  id                :bigint           not null, primary key
#  source_control_id :string
#  pull_request_id   :bigint
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
require 'rails_helper'

RSpec.describe GithubPullRequest, type: :model do
  describe 'associations' do
    it { should have_one(:pull_request).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:source_control_id) }
    it { should validate_presence_of(:pull_request) }
  end
end
