# frozen_string_literal: true

# == Schema Information
#
# Table name: repositories
#
#  id                  :bigint           not null, primary key
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  project_id          :bigint
#  deploy_type         :string
#  supports_deploy     :boolean
#  name                :string
#  jira_project        :string
#  owner               :string
#  friendly_name       :string
#  source_control_type :string
#
require 'rails_helper'

RSpec.describe Repository, type: :model do
  describe 'associations' do
    it { should belong_to(:project).optional(true) }
    it { should have_one(:slack_repository_info).dependent(:destroy) }
    it { should have_many(:pull_requests) }
    it { should have_many(:branches) }
    it { should have_many(:applications) }
  end

  describe 'validations' do
    it {
      should validate_inclusion_of(:deploy_type).in_array([Repository::TAG_DEPLOY_TYPE, Repository::BRANCH_DEPLOY_TYPE])
    }
    it { should validate_presence_of(:friendly_name) }
    it { should validate_presence_of(:source_control_type) }
    it { should validate_uniqueness_of(:friendly_name) }
  end

  describe '#full_name' do
    it 'returns a valid github repository path' do
      repository = FactoryBot.create(:repository, owner: 'google', name: 'search')
      expect(repository.full_name).to eql('google/search')
    end
  end

  describe '#github_link' do
    it 'returns a valid github link' do
      repository = FactoryBot.create(:repository, owner: 'gotham', name: 'city')
      expect(repository.github_link).to eql('https://github.com/gotham/city')
    end
  end

  describe '#application_by_environment' do
    it 'returns the correct application when there are more than one' do
      repository = FactoryBot.create(:repository, owner: 'gotham', name: 'city')
      FactoryBot.create(:application, repository:, environment: 'prod')

      application = FactoryBot.create(:application, repository:, environment: 'qa')

      expect(repository.application_by_environment('qa')).to eql(application)
    end

    it 'returns nil if there are no applications for that environment' do
      repository = FactoryBot.create(:repository, owner: 'gotham', name: 'city')
      FactoryBot.create(:application, repository:, environment: 'prod')

      expect(repository.application_by_environment('qa')).to be_nil
    end
  end
end
