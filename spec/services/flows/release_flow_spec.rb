# frozen_string_literal: true

require 'rails_helper'
require 'external_api_helper'

RSpec.describe Flows::ReleaseFlow, type: :service do
  around do |example|
    ClimateControl.modify SLACK_API_URL: 'https://slack-api.codelitt.dev' do
      example.run
    end
  end

  let(:valid_json) do
    JSON.parse(File.read(File.join('spec', 'fixtures', 'services', 'flows', 'release_tag.json'))).with_indifferent_access
  end

  let(:repository_with_applications) do
    repository = FactoryBot.create(:repository)
    repository.applications << FactoryBot.create(:application, repository: repository, environment: 'prod')
    repository.applications << FactoryBot.create(:application, repository: repository, environment: 'qa')
    repository
  end

  describe '#flow?' do
    context 'returns true' do
      it 'when the json is valid' do
        repository_with_applications
        flow = described_class.new(valid_json)
        expect(flow.flow?).to be_truthy
      end
    end

    context 'returns false' do
      it 'when the environment is different from qa or prod' do
        repository_with_applications

        flow = described_class.new({
                                     text: 'update prodd',
                                     channel_name: 'feed-test-automations'
                                   })
        expect(flow.flow?).to be_falsey
      end

      it 'when the json is valid, but repository does not exist' do
        flow = described_class.new(valid_json)
        expect(flow.flow?).to be_falsey
      end

      it 'when there is more than one repository tied to that slack channel' do
        repository_with_applications
        FactoryBot.create(:repository)

        flow = described_class.new(valid_json)
        expect(flow.flow?).to be_falsey
      end

      it 'when the text message has more than two words' do
        repository_with_applications
        flow = described_class.new({
                                     text: 'update prod roadrunner-rails',
                                     channel_name: 'feed-test-automations'
                                   })
        expect(flow.flow?).to be_falsey
      end
    end
  end

  describe '#execute' do
    context 'with the qa environment' do
      it 'sends a start release notification to the channel' do
        repository_with_applications

        flow = described_class.new({
                                     text: 'update qa',
                                     channel_name: 'feed-test-automations'
                                   })

        expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send).with(
          'Update release to *roadrunner-repository-test* *QA* triggered by @', 'feed-test-automations'
        )
        expect_any_instance_of(Clients::Github::Release).to receive(:list)
        expect_any_instance_of(Flows::SubFlows::ReleaseCandidateFlow).to receive(:execute)

        flow.execute
      end

      it 'calls the release candidate subflow' do
        repository_with_applications

        flow = described_class.new({
                                     text: 'update qa',
                                     channel_name: 'feed-test-automations'
                                   })

        expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send)
        expect_any_instance_of(Clients::Github::Release).to receive(:list)
        expect_any_instance_of(Flows::SubFlows::ReleaseCandidateFlow).to receive(:execute)

        flow.execute
      end

      context 'when it is the first pre-release' do
        it 'creates the first pre-release' do
          VCR.use_cassette('flows#pre-release#first') do
            repository = repository_with_applications
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
              'codelittinc/roadrunner-repository-test',
              'rc.1.v1.0.0',
              'master',
              "Available in the release of *roadrunner-repository-test*:\n - Create README.md [AYAPI-274](https://codelitt.atlassian.net/browse/AYAPI-274)",
              true
            )

            flow.execute
          end
        end
      end

      context 'when it is creating from a pre-release but there are no changes since the last one' do
        it 'sends a message notifying about the fact that there are no changes to deploy' do
          VCR.use_cassette('flows#pre-release#no-changes') do
            repository = repository_with_applications
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

            flow.execute
            expect(message_count).to eql(2)
          end
        end
      end

      context 'when it is creating from a pre-release and there are changes since the last one' do
        it 'creates a new version' do
          VCR.use_cassette('flows#pre-release#new-changes') do
            repository = repository_with_applications
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
              'codelittinc/roadrunner-repository-test',
              'rc.2.v1.0.0',
              'master',
              "Available in the release of *roadrunner-repository-test*:\n - Create .gitignore [AYAPI-276](https://codelitt.atlassian.net/browse/AYAPI-276)",
              true
            )

            flow.execute
          end
        end
      end
    end

    context 'with the prod environment' do
      it 'calls the release candidate subflow' do
        repository_with_applications

        flow = described_class.new({
                                     text: 'update prod',
                                     channel_name: 'feed-test-automations'
                                   })

        expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send)
        expect_any_instance_of(Clients::Github::Release).to receive(:list)
        expect_any_instance_of(Flows::SubFlows::ReleaseStableFlow).to receive(:execute)

        flow.execute
      end

      context 'when it is the first pre-release' do
        it 'creates a new stable release tag from a pre release version' do
          VCR.use_cassette('flows#stable-release#first') do
            repository = repository_with_applications
            repository.slack_repository_info.update(deploy_channel: 'feed-test-automations')

            pr1 = FactoryBot.create(:pull_request, {
                                      title: 'Create .gitignore',
                                      description: 'Card:',
                                      repository: repository
                                    })

            FactoryBot.create(:commit, {
                                sha: '6a65601c32c1915075e800a6779f876442649f55',
                                message: 'Create .gitignore',
                                pull_request: pr1,
                                created_at: DateTime.parse('2020-07-24 12:08:07 UTC')
                              })

            pr2 = FactoryBot.create(:pull_request, {
                                      title: 'Create README.md',
                                      description: 'Card:',
                                      repository: repository,
                                      github_id: 123
                                    })

            FactoryBot.create(:commit, {
                                sha: 'a6a65601c32c1915075e800a6779f876442649f55',
                                message: 'Creating the README.md file',
                                pull_request: pr2,
                                created_at: DateTime.parse('2020-07-24 11:26:10 UTC')
                              })

            flow = described_class.new({
                                         text: 'update prod',
                                         channel_name: 'feed-test-automations'
                                       })

            expect_any_instance_of(Clients::Github::Release).to receive(:create).with(
              'codelittinc/roadrunner-repository-test',
              'v1.0.0',
              'a6a65601c32c1915075e800a6779f876442649f55',
              "Available in the release of *roadrunner-repository-test*:\n - Create README.md \n - Create .gitignore ",
              false
            )

            allow_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send)

            flow.execute
          end
        end

        it 'updates the application version' do
          VCR.use_cassette('flows#stable-release#first') do
            repository = repository_with_applications
            repository.slack_repository_info.update(deploy_channel: 'feed-test-automations')

            pr1 = FactoryBot.create(:pull_request, {
                                      title: 'Create .gitignore',
                                      description: 'Card:',
                                      repository: repository
                                    })

            FactoryBot.create(:commit, {
                                sha: '6a65601c32c1915075e800a6779f876442649f55',
                                message: 'Create .gitignore',
                                pull_request: pr1,
                                created_at: DateTime.parse('2020-07-24 12:08:07 UTC')
                              })

            flow = described_class.new({
                                         text: 'update prod',
                                         channel_name: 'feed-test-automations'
                                       })

            expect_any_instance_of(Clients::Github::Release).to receive(:create)

            allow_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send)

            flow.execute

            prod_application = repository.application_by_environment('prod').reload

            expect(prod_application.version).to eql('v1.0.0')
          end
        end
      end

      context 'when there are no differences from the latest release' do
        it 'sends a message about it' do
          VCR.use_cassette('flows#stable-release#no-changes') do
            repository = repository_with_applications
            repository.slack_repository_info.update(deploy_channel: 'feed-test-automations')

            flow = described_class.new({
                                         text: 'update prod',
                                         channel_name: 'feed-test-automations'
                                       })

            message_count = 0
            allow_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send) { |_arg| message_count += 1 }

            flow.execute
            expect(message_count).to eql(2)
          end
        end
      end

      context 'when it is the second release' do
        it 'creates the release' do
          VCR.use_cassette('flows#stable-release#new-changes') do
            repository = repository_with_applications
            repository.slack_repository_info.update(deploy_channel: 'feed-test-automations')

            pr1 = FactoryBot.create(:pull_request, {
                                      title: 'Create .env.example',
                                      description: 'Card:',
                                      repository: repository
                                    })

            FactoryBot.create(:commit, {
                                sha: '6a65601c32c1915075esssa6779f876442649f55',
                                message: 'Update README.md',
                                pull_request: pr1,
                                created_at: DateTime.parse('2020-08-28 20:43:21 UTC')
                              })

            pr2 = FactoryBot.create(:pull_request, {
                                      title: 'Create README.md',
                                      description: 'Card:',
                                      repository: repository,
                                      github_id: 123
                                    })

            FactoryBot.create(:commit, {
                                sha: 'a6a65601c32c1915075e800a6779f876442649f55',
                                message: 'Update README.md',
                                pull_request: pr2,
                                created_at: DateTime.parse('2020-08-28 20:43:21 UTC')
                              })

            flow = described_class.new({
                                         text: 'update prod',
                                         channel_name: 'feed-test-automations'
                                       })

            expect_any_instance_of(Clients::Github::Release).to receive(:create).with(
              'codelittinc/roadrunner-repository-test',
              'v1.1.0',
              '6a65601c32c1915075esssa6779f876442649f55',
              "Available in the release of *roadrunner-repository-test*:\n - Create .env.example \n - Create README.md ",
              false
            )

            allow_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send)

            flow.execute
          end
        end

        it 'updates the application version' do
          VCR.use_cassette('flows#stable-release#new-changes') do
            repository = repository_with_applications
            repository.slack_repository_info.update(deploy_channel: 'feed-test-automations')

            pr1 = FactoryBot.create(:pull_request, {
                                      title: 'Create .env.example',
                                      description: 'Card:',
                                      repository: repository
                                    })

            FactoryBot.create(:commit, {
                                sha: '6a65601c32c1915075esssa6779f876442649f55',
                                message: 'Update README.md',
                                pull_request: pr1,
                                created_at: DateTime.parse('2020-08-28 20:43:21 UTC')
                              })

            flow = described_class.new({
                                         text: 'update prod',
                                         channel_name: 'feed-test-automations'
                                       })

            expect_any_instance_of(Clients::Github::Release).to receive(:create)

            allow_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send)

            flow.execute

            prod_application = repository.application_by_environment('prod').reload
            expect(prod_application.version).to eql('v1.1.0')
          end
        end
      end

      context 'when there are four commits' do
        it 'uses the latest to create the tag' do
          VCR.use_cassette('flows#stable-release#many-commits') do
            repository = repository_with_applications
            repository.slack_repository_info.update(deploy_channel: 'feed-test-automations')

            pr1 = FactoryBot.create(:pull_request, {
                                      title: 'PR: Update .env 4',
                                      description: 'Card: https://codelitt.atlassian.net/browse/AYAPI-274',
                                      repository: repository
                                    })

            FactoryBot.create(:commit, {
                                sha: '2c6dd08ba0bdf065b7351255afa793f0e5784f25',
                                message: 'Update README.md',
                                pull_request: pr1,
                                created_at: DateTime.parse('2020-08-28 21:05:26 UTC')
                              })

            FactoryBot.create(:commit, {
                                sha: '2c6dd08ba0bdf065b7351255afa793f0e5784f25',
                                message: 'Update README.md',
                                pull_request: pr1,
                                created_at: DateTime.parse('2020-08-28 21:05:26 UTC')
                              })

            pr2 = FactoryBot.create(:pull_request, {
                                      title: 'PR: Update .env 3',
                                      description: 'Card: https://codelitt.atlassian.net/browse/AYAPI-274',
                                      repository: repository,
                                      github_id: 123
                                    })

            FactoryBot.create(:commit, {
                                sha: 'be6cdfeec05baaf93aba94244b98707e94199761',
                                message: 'Update README.md',
                                pull_request: pr2,
                                created_at: DateTime.parse('2020-08-10 21:05:26 UTC')
                              })

            pr3 = FactoryBot.create(:pull_request, {
                                      title: 'PR: Update .env 1',
                                      description: 'Change 1',
                                      repository: repository,
                                      github_id: 124
                                    })

            FactoryBot.create(:commit, {
                                sha: '59254c02079408178f40b12e8192d945988d9644',
                                message: 'Update README.md',
                                pull_request: pr3,
                                created_at: DateTime.parse('2020-08-28 14:50:22 UTC')
                              })

            flow = described_class.new({
                                         text: 'update prod',
                                         channel_name: 'feed-test-automations'
                                       })

            expect_any_instance_of(Clients::Github::Release).to receive(:create).with(
              'codelittinc/roadrunner-repository-test',
              'v1.2.0',
              'be6cdfeec05baaf93aba94244b98707e94199761',
              'Available in the release of *roadrunner-repository-test*:'\
              "\n - PR: Update .env 3 [AYAPI-274](https://codelitt.atlassian.net/browse/AYAPI-274)"\
              "\n - PR: Update .env 1 "\
              "\n - PR: Update .env 4 [AYAPI-274](https://codelitt.atlassian.net/browse/AYAPI-274)",
              false
            )

            allow_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send)

            flow.execute
          end
        end
      end
    end
  end
end
