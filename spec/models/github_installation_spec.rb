# frozen_string_literal: true

# == Schema Information
#
# Table name: github_installations
#
#  id              :bigint           not null, primary key
#  name            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  installation_id :string
#  organization_id :bigint
#
# Indexes
#
#  index_github_installations_on_organization_id  (organization_id)
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
