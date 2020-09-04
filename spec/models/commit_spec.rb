# frozen_string_literal: true

# == Schema Information
#
# Table name: commits
#
#  id              :bigint           not null, primary key
#  sha             :string
#  message         :string
#  author_name     :string
#  author_email    :string
#  pull_request_id :bigint
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
require 'rails_helper'

RSpec.describe Commit, type: :model do
  describe 'should validate the props' do
    it { is_expected.to validate_presence_of(:sha) }
    it { is_expected.to validate_presence_of(:author_name) }
    it { is_expected.to validate_presence_of(:author_email) }
  end

  describe 'associations' do
    it { should belong_to(:pull_request) }
  end
end
