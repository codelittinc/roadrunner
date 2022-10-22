# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GithubInstallation, type: :model do
  describe 'associations' do
    it { should belong_to(:organization) }
  end

  describe 'validations' do
    it { should validate_presence_of(:installation_id) }
  end
end
