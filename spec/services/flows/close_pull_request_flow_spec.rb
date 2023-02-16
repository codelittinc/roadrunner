# frozen_string_literal: true

require 'rails_helper'
require 'external_api_helper'
require 'flows_helper'

RSpec.describe Flows::ClosePullRequestFlow, type: :service do
  around do |example|
    ClimateControl.modify NOTIFICATIONS_API_URL: 'https://api.notifications.codelitt.dev' do
      example.run
    end
  end

  context 'Github JSON' do
    let(:valid_json) { load_flow_fixture('github_close_pull_request.json') }
    let(:cancelled_json) { load_flow_fixture('github_cancel_pull_request.json') }

    let(:repository) do
      FactoryBot.create(:repository, name: 'ay-properties-api')
    end

    describe '#flow?' do
      context 'returns true when' do
        it 'a pull request exists and it is open' do
          FactoryBot.create(:pull_request, source_control_id: 13, repository:)

          flow = described_class.new(valid_json)
          expect(flow.flow?).to be_truthy
        end
      end

      context 'returns false when' do
        it 'a pull request exists but it is closed' do
          pr = FactoryBot.create(:pull_request, source_control_id: 13, repository:)
          pr.merge!

          flow = described_class.new(valid_json)
          expect(flow.flow?).to be_falsey
        end

        it 'a pull request exists but it is cancelled' do
          pr = FactoryBot.create(:pull_request, source_control_id: 13, repository:)
          pr.cancel!

          flow = described_class.new(valid_json)
          expect(flow.flow?).to be_falsey
        end

        it 'a pull request does not exist' do
          flow = described_class.new(valid_json)
          expect(flow.flow?).to be_falsey
        end
      end
    end

    describe '#run' do
      context 'the PR was merged' do
        context 'there is more than one PR with the same github id but different branch' do
          it 'updates the correct pull request state to merged' do
            VCR.use_cassette('flows#close-pull-request#create-commit-right-message') do
              repository2 = FactoryBot.create(:repository, name: 'roadrunner-node')

              slack_message = FactoryBot.create(:slack_message, ts: '123')
              slack_message2 = FactoryBot.create(:slack_message, ts: '1234')

              pr = FactoryBot.create(:pull_request, source_control_id: 13, repository:,
                                                    slack_message:, head: 'fix/update-leases-brokers')
              FactoryBot.create(:pull_request, source_control_id: 13, repository: repository2,
                                               slack_message: slack_message2, head: 'feature/create_feature')

              expect_any_instance_of(Clients::Github::Branch).to receive(:delete)
              expect_any_instance_of(Clients::Notifications::Channel).to receive(:update)
              expect_any_instance_of(Clients::Notifications::Reactji).to receive(:send)

              flow = described_class.new(valid_json)
              flow.run

              expect(pr.reload.state).to eq('merged')
            end
          end
        end

        it 'updates the pull request state to merged' do
          VCR.use_cassette('flows#close-pull-request#create-commit-right-message') do
            slack_message = FactoryBot.create(:slack_message, ts: '123')
            pr = FactoryBot.create(:pull_request, source_control_id: 13, repository:,
                                                  slack_message:, head: 'fix/update-leases-brokers')

            expect_any_instance_of(Clients::Github::Branch).to receive(:delete)
            expect_any_instance_of(Clients::Notifications::Channel).to receive(:update)
            expect_any_instance_of(Clients::Notifications::Reactji).to receive(:send)

            flow = described_class.new(valid_json)
            flow.run

            expect(pr.reload.state).to eq('merged')
          end
        end

        it 'updates the pull request merged_at attr' do
          VCR.use_cassette('flows#close-pull-request#create-commit-right-message') do
            slack_message = FactoryBot.create(:slack_message, ts: '123')
            pr = FactoryBot.create(:pull_request, source_control_id: 13, repository:,
                                                  slack_message:, head: 'fix/update-leases-brokers')

            expect_any_instance_of(Clients::Github::Branch).to receive(:delete)
            expect_any_instance_of(Clients::Notifications::Channel).to receive(:update)
            expect_any_instance_of(Clients::Notifications::Reactji).to receive(:send)

            flow = described_class.new(valid_json)
            flow.run

            expect(pr.reload.merged_at).to_not be_nil
          end
        end

        it 'sends a merge reaction to the slack message' do
          VCR.use_cassette('flows#close-pull-request#create-commit-right-message') do
            slack_message = FactoryBot.create(:slack_message, ts: '123')
            FactoryBot.create(:pull_request, source_control_id: 13, repository:,
                                             slack_message:, head: 'fix/update-leases-brokers')

            expect_any_instance_of(Clients::Github::Branch).to receive(:delete)
            expect_any_instance_of(Clients::Notifications::Channel).to receive(:update)

            flow = described_class.new(valid_json)

            expect_any_instance_of(Clients::Notifications::Reactji).to receive(:send).with('airplane_departure', 'feed-test-automations',
                                                                                           '123')

            flow.run
          end
        end

        it 'creates a set of commits from the pull request in the database' do
          VCR.use_cassette('flows#close-pull-request#create-commit') do
            slack_message = FactoryBot.create(:slack_message, ts: '123')
            FactoryBot.create(:pull_request, source_control_id: 13, repository:,
                                             slack_message:)

            flow = described_class.new(valid_json)

            expect_any_instance_of(Clients::Github::Branch).to receive(:delete)
            expect_any_instance_of(Clients::Notifications::Channel).to receive(:update)

            expect { flow.run }.to change { Commit.count }.by(1)
          end
        end

        it 'creates a set of commits from the pull request in the database with the right message' do
          VCR.use_cassette('flows#close-pull-request#create-commit-right-message') do
            slack_message = FactoryBot.create(:slack_message, ts: '123')
            FactoryBot.create(:pull_request, source_control_id: 13, repository:,
                                             slack_message:)

            expect_any_instance_of(Clients::Github::Branch).to receive(:delete)
            expect_any_instance_of(Clients::Notifications::Channel).to receive(:update)

            flow = described_class.new(valid_json)
            flow.run

            expect(Commit.last.message).to eql('Add PoC for File Upload')
          end
        end
      end

      context 'the PR was cancelled' do
        it 'do not send a direct message to the owner of the pull request if it was cancelled' do
          VCR.use_cassette('flows#close-pull-request#create-commit-right-message') do
            slack_message = FactoryBot.create(:slack_message, ts: '123')
            FactoryBot.create(:pull_request, source_control_id: 13, repository:,
                                             slack_message:)

            expect_any_instance_of(Clients::Github::Branch).to receive(:delete)
            expect_any_instance_of(Clients::Notifications::Channel).to receive(:update)

            flow = described_class.new(cancelled_json)
            message_count = 0
            allow_any_instance_of(Clients::Notifications::Direct).to receive(:send) { |_arg| message_count += 1 }

            flow.run
            expect(message_count).to eql(0)
          end
        end

        it 'sends a cancel reaction if the pr was cancelled' do
          VCR.use_cassette('flows#close-pull-request#create-commit-right-message') do
            slack_message = FactoryBot.create(:slack_message, ts: '123')
            FactoryBot.create(:pull_request, source_control_id: 13, repository:,
                                             slack_message:)

            expect_any_instance_of(Clients::Github::Branch).to receive(:delete)
            expect_any_instance_of(Clients::Notifications::Channel).to receive(:update)

            flow = described_class.new(cancelled_json)

            expect_any_instance_of(Clients::Notifications::Reactji).to receive(:send).with('x',
                                                                                           'feed-test-automations', '123')

            flow.run
          end
        end
      end

      it 'sends a direct message to the owner of the pull request' do
        VCR.use_cassette('flows#close-pull-request#create-commit-right-message') do
          slack_message = FactoryBot.create(:slack_message, ts: '123')
          FactoryBot.create(:pull_request, source_control_id: 13, repository:, slack_message:)

          expect_any_instance_of(Clients::Github::Branch).to receive(:delete)
          expect_any_instance_of(Clients::Notifications::Channel).to receive(:update)

          expect_any_instance_of(Clients::Notifications::Direct).to receive(:send).with(
            ':airplane_departure: Pull Request closed <https://github.com/codelittinc/ay-properties-api/pull/13|ay-properties-api#13>. ' \
            'Please update the status of the cards: <https://codelitt.atlassian.net/browse/AYAPI-254|#AYAPI-254>,<https://codelitt.atlassian.net/browse/AYAPI-255|#AYAPI-255>.',
            'kaiomagalhaes', true
          )

          flow = described_class.new(valid_json)
          flow.run
        end
      end
    end
  end

  context 'Azure JSON' do
    let(:valid_json) { load_flow_fixture('azure_close_pull_request.json') }

    let(:abandoned_json) { load_flow_fixture('azure_abandoned_pull_request.json') }

    let(:repository) do
      FactoryBot.create(:repository, name: 'ay-users-api-test', owner: 'Avant')
    end

    describe '#flow?' do
      context 'returns true when' do
        it 'a pull request exists, is open and the eventType is git.pullrequest.merged' do
          FactoryBot.create(:pull_request, source_control_id: 35, repository:)

          flow = described_class.new(valid_json)
          expect(flow.flow?).to be_truthy
        end

        it 'a pull request exists, is open and the eventType is git.pullrequest.updated' do
          FactoryBot.create(:pull_request, source_control_id: 35, repository:)

          azure_merge_json_update = valid_json.deep_dup
          azure_merge_json_update[:eventType] = 'git.pullrequest.updated'
          flow = described_class.new(azure_merge_json_update)
          expect(flow.flow?).to be_truthy
        end

        it 'a pull request is abandoned' do
          FactoryBot.create(:pull_request, source_control_id: 35, repository:)

          flow = described_class.new(abandoned_json)
          expect(flow.flow?).to be_truthy
        end
      end

      context 'returns false when' do
        it 'a pull request exists but it is closed' do
          pr = FactoryBot.create(:pull_request, source_control_id: 35, repository:)
          pr.merge!

          flow = described_class.new(valid_json)
          expect(flow.flow?).to be_falsey
        end

        it 'a pull request exists but it is cancelled' do
          pr = FactoryBot.create(:pull_request, source_control_id: 35, repository:)
          pr.cancel!

          flow = described_class.new(valid_json)
          expect(flow.flow?).to be_falsey
        end

        it 'a pull request does not exist' do
          flow = described_class.new(valid_json)
          expect(flow.flow?).to be_falsey
        end
      end
    end

    describe '#run' do
      context 'the PR was merged' do
        context 'there is more than one PR with the same azure id but different branch' do
          it 'updates the correct pull request state to merged' do
            VCR.use_cassette('flows#close-pull-request#azure-create-commit-right-message') do
              repository2 = FactoryBot.create(:repository, name: 'roadrunner-node')

              slack_message = FactoryBot.create(:slack_message, ts: '123')
              slack_message2 = FactoryBot.create(:slack_message, ts: '1234')

              pr = FactoryBot.create(:pull_request, source_control_id: 35, repository:,
                                                    slack_message:, head: 'fix/update-leases-brokers')
              FactoryBot.create(:pull_request, source_control_id: 35, repository: repository2,
                                               slack_message: slack_message2, head: 'feature/create_feature')

              expect_any_instance_of(Clients::Notifications::Channel).to receive(:update)
              expect_any_instance_of(Clients::Notifications::Reactji).to receive(:send)

              flow = described_class.new(valid_json)
              flow.run

              expect(pr.reload.state).to eq('merged')
            end
          end
        end

        it 'updates the pull request state to merged' do
          VCR.use_cassette('flows#close-pull-request#azure-create-commit-right-message') do
            slack_message = FactoryBot.create(:slack_message, ts: '123')
            pr = FactoryBot.create(:pull_request, source_control_id: 35, repository:,
                                                  slack_message:, head: 'fix/update-leases-brokers')

            expect_any_instance_of(Clients::Notifications::Channel).to receive(:update)
            expect_any_instance_of(Clients::Notifications::Reactji).to receive(:send)

            flow = described_class.new(valid_json)
            flow.run

            expect(pr.reload.state).to eq('merged')
          end
        end

        it 'updates the pull request state from abandoned to canceled' do
          VCR.use_cassette('flows#close-pull-request#azure-create-commit-right-message') do
            slack_message = FactoryBot.create(:slack_message, ts: '123')
            pr = FactoryBot.create(:pull_request, source_control_id: 35, repository:,
                                                  slack_message:, head: 'fix/update-leases-brokers')

            expect_any_instance_of(Clients::Notifications::Channel).to receive(:update)
            expect_any_instance_of(Clients::Notifications::Reactji).to receive(:send)

            flow = described_class.new(abandoned_json)
            flow.run

            expect(pr.reload.state).to eq('cancelled')
          end
        end

        it 'sends a merge reaction to the slack message' do
          VCR.use_cassette('flows#close-pull-request#azure-create-commit-right-message') do
            slack_message = FactoryBot.create(:slack_message, ts: '123')
            FactoryBot.create(:pull_request, source_control_id: 35, repository:,
                                             slack_message:, head: 'fix/update-leases-brokers')

            expect_any_instance_of(Clients::Notifications::Channel).to receive(:update)

            flow = described_class.new(valid_json)

            expect_any_instance_of(Clients::Notifications::Reactji).to receive(:send).with('airplane_departure', 'feed-test-automations',
                                                                                           '123')

            flow.run
          end
        end

        it 'creates a set of commits from the pull request in the database' do
          VCR.use_cassette('flows#close-pull-request#azure-create-commit-right-message') do
            slack_message = FactoryBot.create(:slack_message, ts: '123')
            FactoryBot.create(:pull_request, source_control_id: 35, repository:,
                                             slack_message:)

            flow = described_class.new(valid_json)

            expect_any_instance_of(Clients::Notifications::Channel).to receive(:update)

            expect { flow.run }.to change { Commit.count }.by(1)
          end
        end

        it 'creates a set of commits from the pull request in the database with the right message' do
          VCR.use_cassette('flows#close-pull-request#azure-create-commit-right-message') do
            slack_message = FactoryBot.create(:slack_message, ts: '123')
            FactoryBot.create(:pull_request, source_control_id: 35, repository:,
                                             slack_message:)

            expect_any_instance_of(Clients::Notifications::Channel).to receive(:update)

            flow = described_class.new(valid_json)
            flow.run

            expect(Commit.last.message).to eql('Added test')
          end
        end
      end

      it 'sends a direct message to the owner of the pull request' do
        VCR.use_cassette('flows#close-pull-request#azure-create-commit-right-message') do
          slack_message = FactoryBot.create(:slack_message, ts: '123')
          FactoryBot.create(:pull_request, source_control_id: 35, repository:, slack_message:,
                                           source_control_type: 'azure')

          expect_any_instance_of(Clients::Notifications::Channel).to receive(:update)

          expect_any_instance_of(Clients::Notifications::Direct).to receive(:send).with(
            ':airplane_departure: Pull Request closed <https://dev.azure.com/AY-InnovationCenter/Avant/_git/ay-users-api-test/pullrequest/35|ay-users-api-test#35>',
            'kaiomagalhaes',
            true
          )

          flow = described_class.new(valid_json)
          flow.run
        end
      end

      it 'sends a direct message to the owner of the pull request asking him to update the card' do
        VCR.use_cassette('flows#close-pull-request#azure-create-commit-right-message') do
          pr_description = '### Other minor changes:
            - Move files out to a utils file in UploadSection to shorten the file size and improve readability.
          ### Card Link:
          https://dev.azure.com/AY-InnovationCenter/Avant/_workitems/edit/1427/
          ### Design Expected Screenshot
          ![image](https://user-images.githubusercontent.com/68696952/115034665.png)
          ### Implementation Screenshot or GIF
          ![Property Intelligence](https://user-images.githubusercontent.com/68696952.gif)
          https://dev.azure.com/AY-InnovationCenter/e57bfb9f-c5eb-4f96-9f83-8a98a76bfda4/_apis/git/repositories/93ed8322-6ef9-4c87-a458-b3d0859de666/pullRequests/348/attachments/Screenshot
          ### Example Link:
          https://dev.azure.com/AY-InnovationCenter/Avant/_workitems/edit/1346
          ### Notes:
          Still WIP'

          slack_message = FactoryBot.create(:slack_message, ts: '123')
          FactoryBot.create(:pull_request, source_control_id: 35, repository:, slack_message:,
                                           source_control_type: 'azure')

          expect_any_instance_of(Parsers::AzureWebhookSourceControlParser).to receive(:description).and_return(pr_description)
          expect_any_instance_of(Clients::Notifications::Channel).to receive(:update)

          expect_any_instance_of(Clients::Notifications::Direct).to receive(:send).with(
            ':airplane_departure: Pull Request closed <https://dev.azure.com/AY-InnovationCenter/Avant/_git/ay-users-api-test/pullrequest/35|ay-users-api-test#35>. ' \
            'Please update the status of the cards: <https://dev.azure.com/AY-InnovationCenter/Avant/_workitems/edit/1427/|#1427>,<https://dev.azure.com/AY-InnovationCenter/Avant/_workitems/edit/1346|#1346>.',
            'kaiomagalhaes',
            true
          )

          flow = described_class.new(valid_json)
          flow.run
        end
      end
    end
  end
end
