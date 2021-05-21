# frozen_string_literal: true

require 'rails_helper'
require 'external_api_helper'
require 'flows_helper'

# We need to use the Flows::ReleaseFlow since it prepares the execution of the ReleaseCandidateFlow
RSpec.describe Flows::ReleaseFlow, type: :service do
  around do |example|
    ClimateControl.modify SLACK_API_URL: 'https://slack-api.codelitt.dev' do
      example.run
    end
  end

  let(:valid_json) do
    {
      text: 'update qa',
      channel_name: 'feed-test-automations'
    }
  end

  context 'when the repository type is Github' do
    let(:github_repository_with_applications) do
      repository = FactoryBot.create(:repository, owner: 'codelittinc', name: 'roadrunner-repository-test', source_control_type: 'github')
      repository.applications << FactoryBot.create(:application, repository: repository, environment: 'qa')
      repository
    end

    describe '#run' do
      context 'when it is the first pre-release' do
        it 'creates the first pre-release' do
          VCR.use_cassette('flows#pre-release#first') do
            repository = github_repository_with_applications
            repository.slack_repository_info.update(deploy_channel: 'feed-test-automations')

            pull_request = FactoryBot.create(:pull_request, {
                                               title: 'Create README.md',
                                               description: 'Card: [AYAPI-274](https://codelitt.atlassian.net/browse/AYAPI-274)',
                                               repository: repository
                                             })

            FactoryBot.create(:commit, {
                                sha: '43b58be5634e022d16a10b886a80e3c0be2ee3a9',
                                message: "Merge branch 'master' into Rheniery-patch-1",
                                pull_request: pull_request,
                                created_at: DateTime.parse('2020-08-28 18:33:57 UTC')
                              })

            flow = described_class.new(valid_json)

            expect_any_instance_of(Clients::Github::Release).to receive(:create).with(
              github_repository_with_applications,
              'rc.1.v1.0.0',
              'master',
              "Available in the release of *roadrunner-repository-test*:\n - Merge branch 'master' into Rheniery-patch-1 [AYAPI-274](https://codelitt.atlassian.net/browse/AYAPI-274)",
              true
            )

            flow.run
          end
        end
      end

      context 'when it is creating from a pre-release but there are no changes since the last one' do
        it 'sends a message notifying about the fact that there are no changes to deploy' do
          VCR.use_cassette('flows#pre-release#no-changes') do
            repository = github_repository_with_applications
            repository.slack_repository_info.update(deploy_channel: 'feed-test-automations')

            repository = FactoryBot.create(:pull_request, {
                                             title: 'Create README.md',
                                             description: 'Card: https://codelitt.atlassian.net/browse/AYAPI-274',
                                             repository: repository
                                           })

            FactoryBot.create(:commit, {
                                sha: '43b58be5634e022d16a10b886a80e3c0be2ee3a9',
                                message: "Merge branch 'master' into Rheniery-patch-1",
                                pull_request: repository,
                                created_at: DateTime.parse('2020-08-28 18:33:57 UTC')
                              })

            flow = described_class.new(valid_json)

            message_count = 0
            allow_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send) { |_arg| message_count += 1 }

            flow.run
            expect(message_count).to eql(2)
          end
        end
      end

      context 'when it is creating from a pre-release and there are changes since the last one' do
        it 'creates a new version' do
          VCR.use_cassette('flows#pre-release#new-changes') do
            repository = github_repository_with_applications
            repository.slack_repository_info.update(deploy_channel: 'feed-test-automations')

            pull_request = FactoryBot.create(:pull_request, {
                                               title: 'Create .gitignore',
                                               description: 'Card: [AYAPI-276](https://codelitt.atlassian.net/browse/AYAPI-276)',
                                               repository: repository
                                             })

            FactoryBot.create(:commit, {
                                sha: '43b58be5634e022d16a10b886a80e3c0be2ee3a9',
                                message: "Merge branch 'master' into Rheniery-patch-1",
                                pull_request: pull_request,
                                created_at: DateTime.parse('2020-08-28 18:33:57 UTC')
                              })

            flow = described_class.new(valid_json)

            expect_any_instance_of(Clients::Github::Release).to receive(:create).with(
              github_repository_with_applications,
              'rc.2.v1.0.0',
              'master',
              "Available in the release of *roadrunner-repository-test*:\n - Merge branch 'master' into Rheniery-patch-1 [AYAPI-276](https://codelitt.atlassian.net/browse/AYAPI-276)",
              true
            )

            flow.run
          end
        end
      end
    end
  end
end
