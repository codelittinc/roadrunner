# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Release, type: :model do
  describe 'associations' do
    it { should belong_to(:application) }
  end

  describe 'validations' do
    it { should validate_presence_of(:version) }
  end
end
