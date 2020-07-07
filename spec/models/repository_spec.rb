require 'rails_helper'

RSpec.describe Repository, type: :model do
  describe 'associations' do
    it { should have_many(:servers) }
    it { should belong_to(:project) }
  end

  describe 'validations' do
    it { should validate_inclusion_of(:deploy_type).in_array([Repository::TAG_DEPLOY_TYPE, Repository::BRANCH_DEPLOY_TYPE]) }
  end
end
