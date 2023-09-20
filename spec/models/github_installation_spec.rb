# frozen_string_literal: true

# == Schema Information
#
# Table name: github_installations
#
#  id              :bigint           not null, primary key
#  installation_id :string
#  organization_id :bigint
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  name            :string
#
require 'rails_helper'

RSpec.describe GithubInstallation, type: :model do
  describe 'associations' do
    it { should belong_to(:organization) }
  end

  describe 'validations' do
    it { should validate_presence_of(:installation_id) }
  end
end
