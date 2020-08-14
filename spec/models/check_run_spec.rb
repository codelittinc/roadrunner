require 'rails_helper'

RSpec.describe CheckRun, type: :model do
  describe 'should validate the props' do
    it { is_expected.to validate_presence_of(:state) }
  end
end
