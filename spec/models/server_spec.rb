require 'rails_helper'

RSpec.describe Server, type: :model do
  describe 'associations' do
    it { should belong_to(:repository) }
  end

  describe 'validations' do
    it { should validate_presence_of(:link) }
    it { should validate_presence_of(:repository) }
  end
end
