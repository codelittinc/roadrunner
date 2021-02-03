# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserAdmin, type: :model do
  describe 'should validate the props' do
    it { is_expected.to validate_presence_of(:username) }
    it { is_expected.to validate_presence_of(:email) }
  end
end
