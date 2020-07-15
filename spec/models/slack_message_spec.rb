require 'rails_helper'

RSpec.describe SlackMessage, type: :model do
  describe 'associations' do
    it { should belong_to(:pull_request).optional }
  end

  describe 'validations' do
    it { should validate_presence_of(:ts) }
  end
end
