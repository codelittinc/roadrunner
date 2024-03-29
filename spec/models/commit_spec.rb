# frozen_string_literal: true

# == Schema Information
#
# Table name: commits
#
#  id              :bigint           not null, primary key
#  author_email    :string
#  author_name     :string
#  message         :string
#  sha             :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  pull_request_id :bigint
#
# Indexes
#
#  index_commits_on_pull_request_id  (pull_request_id)
#
require 'rails_helper'

RSpec.describe Commit, type: :model do
  describe 'should validate the props' do
    it { is_expected.to validate_presence_of(:sha) }
    it { is_expected.to validate_presence_of(:author_name) }
  end

  describe 'associations' do
    it { should belong_to(:pull_request) }
    it { should have_many(:commit_releases).dependent(:destroy) }
    it { should have_many(:releases).through(:commit_releases) }
  end
end
