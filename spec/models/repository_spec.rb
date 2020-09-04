# frozen_string_literal: true

# == Schema Information
#
# Table name: repositories
#
#  id              :bigint           not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  project_id      :bigint
#  deploy_type     :string
#  supports_deploy :boolean
#  name            :string
#  jira_project    :string
#  alias           :string
#
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
