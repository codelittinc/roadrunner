# == Schema Information
#
# Table name: repositories
#
#  id              :bigint           not null, primary key
#  alias           :string
#  deploy_type     :string
#  jira_project    :string
#  name            :string
#  supports_deploy :boolean
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  project_id      :bigint
#
# Indexes
#
#  index_repositories_on_project_id  (project_id)
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
