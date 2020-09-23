# frozen_string_literal: true

require 'rails_helper'
# require 'external_api_helper'

RSpec.describe Flows::GraylogsErrorNotificationFlow, type: :service do
  let(:incident_big_message) do
    JSON.parse(File.read(File.join('spec', 'fixtures', 'services', 'flows', 'graylogs_incident_big_message.json'))).with_indifferent_access
  end

  let(:incident_small_message) do
    JSON.parse(File.read(File.join('spec', 'fixtures', 'services', 'flows', 'graylogs_incident_small_message.json'))).with_indifferent_access
  end

  describe '#flow?' do
    context 'when event_definition_title exists' do
      it 'returns true' do
        FactoryBot.create(:server, link: 'roadrunner.codelitt.dev', name: 'test')

        flow = described_class.new(incident_big_message)
        expect(flow.flow?).to be_truthy
      end
    end

    context 'when event_definition_title does not exist' do
      it 'returns false' do
        FactoryBot.create(:server, link: 'roadrunner.codelitt.dev', name: 'test')
        flow = described_class.new({
                                     event_definition_title: nil
                                   })
        expect(flow.flow?).to be_falsey
      end
    end

    context 'when the source exists' do
      it 'returns true' do
        FactoryBot.create(:server, link: 'roadrunner.codelitt.dev', name: 'test')
        flow = described_class.new(incident_big_message)
        expect(flow.flow?).to be_truthy
      end
    end

    context 'when the source does not exist' do
      it 'returns false' do
        flow = described_class.new(incident_big_message)
        expect(flow.flow?).to be_falsey
      end
    end
  end

  describe '#run' do
    context 'with a valid json in which the message is bigger than 150 chars' do
      it 'creates a new ServerIncident record' do
        FactoryBot.create(:server, link: 'roadrunner.codelitt.dev', name: 'test')

        flow = described_class.new(incident_small_message)
        expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send).and_return({
                                                                                              ts: 1
                                                                                            })
        expect { flow.execute }.to change { ServerIncident.count }.by(1)
      end

      it 'calls ChannelMessage#send with the right params only once' do
        FactoryBot.create(:server, link: 'roadrunner.codelitt.dev', environment: 'prod', name: 'test')

        flow = described_class.new(incident_small_message)
        expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send).with(
          ":fire: <https://github.com/codelittinc/roadrunner-repository-test|roadrunner-repository-test> environment :fire:<roadrunner.codelitt.dev|PROD>:fire: \n "\
          '```{ [GraphQLasdEsrraoar: Variable "$propearty" got invalid value { id: 520 } }```',
          'feed-test-automations'
        ).and_return({
                       ts: 1
                     })
        flow.run
      end
    end

    context 'when no slack message was send 10 minutes before' do
      it 'sends a slack message' do
        FactoryBot.create(:server, link: 'roadrunner.codelitt.dev', name: 'test')

        flow = described_class.new(incident_small_message)

        expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send).and_return({
                                                                                              ts: 1
                                                                                            })

        flow.run
      end
    end

    context 'when the slack_repository_info of the server repository has both the deploy channel and feed channel' do
      it 'sends a slack message to the feed channel' do
        server = FactoryBot.create(:server, link: 'roadrunner.codelitt.dev', environment: 'prod', name: 'test')
        server.repository.slack_repository_info.update({
                                                         feed_channel: 'my-cool-feed-repository-channel',
                                                         deploy_channel: 'deploy-channel'
                                                       })

        flow = described_class.new(incident_small_message)

        expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send).with(
          ":fire: <https://github.com/codelittinc/roadrunner-repository-test|roadrunner-repository-test> environment :fire:<roadrunner.codelitt.dev|PROD>:fire: \n "\
          '```{ [GraphQLasdEsrraoar: Variable "$propearty" got invalid value { id: 520 } }```',
          'my-cool-feed-repository-channel'
        ).and_return({
                       ts: 1
                     })

        flow.run
      end
    end

    context 'when the slack_repository_info of the server repository has only the deploy channel' do
      it 'sends a slack message to the feed channel' do
        server = FactoryBot.create(:server, link: 'roadrunner.codelitt.dev', environment: 'prod', name: 'test')
        server.repository.slack_repository_info.update({
                                                         feed_channel: nil,
                                                         deploy_channel: 'deploy-channel'
                                                       })

        flow = described_class.new(incident_small_message)

        expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send).with(
          ":fire: <https://github.com/codelittinc/roadrunner-repository-test|roadrunner-repository-test> environment :fire:<roadrunner.codelitt.dev|PROD>:fire: \n "\
          '```{ [GraphQLasdEsrraoar: Variable "$propearty" got invalid value { id: 520 } }```',
          'deploy-channel'
        ).and_return({
                       ts: 1
                     })

        flow.run
      end
    end
  end
end
