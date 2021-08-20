# frozen_string_literal: true

require 'rails_helper'
require 'external_api_helper'
require 'flows_helper'

RSpec.describe Flows::SourceControl::NewPullRequestFlow, type: :service do
  let(:github_valid_json) { load_flow_fixture('github_new_pull_request.json') }
  let(:azure_valid_json) { load_flow_fixture('azure_new_pull_request.json') }

  context 'Github JSON' do
    let(:repository) do
      FactoryBot.create(:repository, name: 'roadrunner-rails', owner: 'codelittinc')
    end

    describe '#flow?' do
      context 'returns true' do
        it 'when it has the opened action and does not exist the pull request in database' do
          repository
          github_valid_json_confirmed = github_valid_json.deep_dup
          github_valid_json_confirmed[:number] = 1
          github_valid_json_confirmed[:action] = 'opened'
          flow = described_class.new(github_valid_json_confirmed)
          expect(flow.flow?).to be_truthy
        end

        it 'when it has the ready_for_review action and does not exist the pull request in database' do
          repository
          github_valid_json_confirmed = github_valid_json.deep_dup
          github_valid_json_confirmed[:number] = 1
          github_valid_json_confirmed[:action] = 'ready_for_review'
          flow = described_class.new(github_valid_json_confirmed)
          expect(flow.flow?).to be_truthy
        end
      end

      context 'return false when' do
        it 'when the action is different from opened or ready_for_review' do
          ingithub_valid_json = github_valid_json.deep_dup
          ingithub_valid_json[:action] = 'dfsdfsdf'
          flow = described_class.new(ingithub_valid_json)
          expect(flow.flow?).to be_falsey
        end

        it 'pull request already exists in database' do
          FactoryBot.create(:pull_request, repository: repository, source_control_id: 160)

          flow = described_class.new(github_valid_json)
          expect(flow.flow?).to be_falsey
        end

        it 'there is no repository with the given name' do
          flow = described_class.new(github_valid_json)
          expect(flow.flow?).to be_falsey
        end
      end
    end

    describe '#execute' do
      it 'creates a PullRequest in the database' do
        repository
        expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send).and_return({
                                                                                              'ts' => '123'
                                                                                            })
        expect_any_instance_of(Clients::Slack::Reactji).to receive(:send)
        flow = described_class.new(github_valid_json)

        expect { flow.run }.to change(PullRequest, :count).by(1)
      end

      context 'pull request already exists in database' do
        it 'pull request already exists in database' do
          FactoryBot.create(:pull_request, repository: repository, source_control_id: 160)

          flow = described_class.new(github_valid_json)

          expect { flow.run }.to change(PullRequest, :count).by(0)
        end
      end

      context 'there is a racing condition and two events are triggered together' do
        it 'does not create more than one pull request' do
          FactoryBot.create(:pull_request, repository: repository, source_control_id: 160)

          expect_any_instance_of(Flows::SourceControl::NewPullRequestFlow).to receive(:pull_request_already_exists?).and_return(true)
          flow = described_class.new(github_valid_json)

          expect { flow.run }.to change(PullRequest, :count).by(0)
        end
      end

      context 'when there is a check run linked with the branch of the pull request' do
        it 'and it state is success, sends a success reaction' do
          branch = FactoryBot.create(:branch, name: 'kaiomagalhaes-patch-111', repository: repository)
          FactoryBot.create(:check_run, state: 'success', branch: branch)

          expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send).and_return({
                                                                                                'ts' => '123'
                                                                                              })
          expect_any_instance_of(Clients::Slack::Reactji).to receive(:send).with('white_check_mark',
                                                                                 'feed-test-automations', '123')

          flow = described_class.new(github_valid_json)

          flow.run
        end

        it 'and it state is failure, sends a failure reaction' do
          branch = FactoryBot.create(:branch, name: 'kaiomagalhaes-patch-111', repository: repository)
          FactoryBot.create(:check_run, state: 'failure', branch: branch)

          expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send).and_return({
                                                                                                'ts' => '123'
                                                                                              })
          expect_any_instance_of(Clients::Slack::Reactji).to receive(:send).with('rotating_light',
                                                                                 'feed-test-automations', '123')

          flow = described_class.new(github_valid_json)

          flow.run
        end

        it 'and it state is pending, sends a pending reaction' do
          branch = FactoryBot.create(:branch, name: 'kaiomagalhaes-patch-111', repository: repository)
          FactoryBot.create(:check_run, state: 'pending', branch: branch)

          expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send).and_return({
                                                                                                'ts' => '123'
                                                                                              })
          expect_any_instance_of(Clients::Slack::Reactji).to receive(:send).with('hourglass', 'feed-test-automations',
                                                                                 '123')

          flow = described_class.new(github_valid_json)

          flow.run
        end
      end

      context 'when there is not a check run linked with the branch of the pull request' do
        it 'sends a pending reaction' do
          repository
          expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send).and_return({
                                                                                                'ts' => '123'
                                                                                              })
          expect_any_instance_of(Clients::Slack::Reactji).to receive(:send).with('hourglass', 'feed-test-automations',
                                                                                 '123')

          flow = described_class.new(github_valid_json)

          flow.run
        end
      end
    end
  end

  context 'Azure JSON' do
    let(:repository) do
      FactoryBot.create(:repository, name: 'ay-users-api-test', owner: 'Avant')
    end

    describe '#flow?' do
      context 'returns true' do
        it 'when it has the pull request created eventType and does not exist the pull request in database' do
          repository
          azure_valid_json_updated = azure_valid_json.deep_dup
          azure_valid_json_updated[:resource][:pullRequestId] = 1
          azure_valid_json_updated[:eventType] = 'git.pullrequest.created'
          flow = described_class.new(azure_valid_json_updated)
          expect(flow.flow?).to be_truthy
        end
      end

      context 'return false when' do
        it 'when the eventType is different from git.pullrequest.created' do
          repository
          azure_valid_json_updated = azure_valid_json.deep_dup
          azure_valid_json_updated[:eventType] = 'dfsdfsdf'
          flow = described_class.new(azure_valid_json_updated)
          expect(flow.flow?).to be_falsey
        end

        it 'pull request already exists in database' do
          repository
          FactoryBot.create(:pull_request, repository: repository, source_control_id: 35)

          flow = described_class.new(azure_valid_json)
          expect(flow.flow?).to be_falsey
        end

        it 'there is no repository with the given name' do
          flow = described_class.new(azure_valid_json)
          expect(flow.flow?).to be_falsey
        end
      end
    end

    describe '#execute' do
      it 'creates a PullRequest in the database' do
        repository
        expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send).and_return({
                                                                                              'ts' => '123'
                                                                                            })
        expect_any_instance_of(Clients::Slack::Reactji).to receive(:send)
        flow = described_class.new(azure_valid_json)

        expect { flow.run }.to change { PullRequest.count }.by(1)
      end

      it 'creates a SlackMessage in the database' do
        repository
        expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send).and_return({
                                                                                              'ts' => '123'
                                                                                            })
        expect_any_instance_of(Clients::Slack::Reactji).to receive(:send)

        flow = described_class.new(azure_valid_json)

        expect { flow.run }.to change { SlackMessage.count }.by(1)
      end

      # @TODO: add checkrun flow for azure
      #      context 'when there is a check run linked with the branch of the pull request' do
      #   it 'and it state is success, sends a success reaction' do
      #     repository = FactoryBot.create(:repository, name: 'ay-users-api-test')
      #     branch = FactoryBot.create(:branch, name: 'kaiomagalhaes-patch-111', repository: repository)
      #     FactoryBot.create(:check_run, state: 'success', branch: branch)

      #     expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send).and_return({
      #                                                                                           'ts' => '123'
      #                                                                                         })
      #     expect_any_instance_of(Clients::Slack::Reactji).to receive(:send).with('white_check_mark', 'feed-test-automations', '123')

      #     flow = described_class.new(azure_valid_json)

      #     flow.run
      #   end

      #   it 'and it state is failure, sends a failure reaction' do
      #     repository = FactoryBot.create(:repository, name: 'ay-users-api-test')
      #     branch = FactoryBot.create(:branch, name: 'kaiomagalhaes-patch-111', repository: repository)
      #     FactoryBot.create(:check_run, state: 'failure', branch: branch)

      #     expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send).and_return({
      #                                                                                           'ts' => '123'
      #                                                                                         })
      #     expect_any_instance_of(Clients::Slack::Reactji).to receive(:send).with('rotating_light', 'feed-test-automations', '123')

      #     flow = described_class.new(azure_valid_json)

      #     flow.run
      #   end

      #   it 'and it state is pending, sends a pending reaction' do
      #     repository = FactoryBot.create(:repository, name: 'ay-users-api-test')
      #     branch = FactoryBot.create(:branch, name: 'kaiomagalhaes-patch-111', repository: repository)
      #     FactoryBot.create(:check_run, state: 'pending', branch: branch)

      #     expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send).and_return({
      #                                                                                           'ts' => '123'
      #                                                                                         })
      #     expect_any_instance_of(Clients::Slack::Reactji).to receive(:send).with('hourglass', 'feed-test-automations', '123')

      #     flow = described_class.new(azure_valid_json)

      #     flow.run
      #   end
      # end

      context 'when there is not a check run linked with the branch of the pull request' do
        it 'sends a pending reaction' do
          repository
          expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send).and_return({
                                                                                                'ts' => '123'
                                                                                              })
          expect_any_instance_of(Clients::Slack::Reactji).to receive(:send).with('hourglass', 'feed-test-automations',
                                                                                 '123')

          flow = described_class.new(azure_valid_json)

          flow.run
        end
      end
    end
  end
end