# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Organization, type: :model do
  describe 'associations' do
    it { should have_many(:github_installations).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:notifications_id) }
    it { should validate_presence_of(:notifications_key) }
    it { should validate_presence_of(:name) }
  end
end
