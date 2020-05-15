require 'rails_helper'

RSpec.describe SlackRepositoryInfo, type: :model do
  describe 'associations' do
    it { should belong_to(:repository) }
  end

  describe 'validations' do
    it { should validate_presence_of(:deploy_channel) }
    it { should validate_presence_of(:repository) }
  end
end
