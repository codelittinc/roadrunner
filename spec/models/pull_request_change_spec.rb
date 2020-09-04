# frozen_string_literal: true

# == Schema Information
#
# Table name: pull_request_changes
#
#  id              :bigint           not null, primary key
#  pull_request_id :bigint           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
require 'rails_helper'

RSpec.describe PullRequestChange, type: :model do
  describe 'associations' do
    it { should belong_to(:pull_request) }
  end
end
