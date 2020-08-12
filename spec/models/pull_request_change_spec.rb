require 'rails_helper'

RSpec.describe PullRequestChange, type: :model do
  describe 'associations' do
    it { should belong_to(:pull_request) }
  end
end
