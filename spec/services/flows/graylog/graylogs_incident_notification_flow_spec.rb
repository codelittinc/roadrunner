# frozen_string_literal: true

require 'rails_helper'
# require 'external_api_helper'

RSpec.describe Flows::Graylog::GraylogsIncidentNotificationFlow, type: :service do
  let(:incident_big_message) do
    JSON.parse(File.read(File.join('spec', 'fixtures', 'services', 'flows',
                                   'graylogs_incident_big_message.json'))).with_indifferent_access
  end

  let(:incident_small_message) do
    JSON.parse(File.read(File.join('spec', 'fixtures', 'services', 'flows',
                                   'graylogs_incident_small_message.json'))).with_indifferent_access
  end

  describe '#flow?' do
    context 'when event_definition_title exists' do
      it 'returns true' do
        FactoryBot.create(:application, :with_server, external_identifier: 'roadrunner.codelitt.dev')

        flow = described_class.new(incident_big_message)
        expect(flow.flow?).to be_truthy
      end
    end

    context 'when event_definition_title does not exist' do
      it 'returns false' do
        FactoryBot.create(:application, :with_server, external_identifier: 'roadrunner.codelitt.dev')

        flow = described_class.new({
                                     event_definition_title: nil
                                   })
        expect(flow.flow?).to be_falsey
      end
    end

    context 'when the source exists' do
      it 'returns true' do
        FactoryBot.create(:application, :with_server, external_identifier: 'roadrunner.codelitt.dev')

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
        FactoryBot.create(:application, :with_server, external_identifier: 'roadrunner.codelitt.dev', environment: 'qa')

        flow = described_class.new(incident_small_message)
        expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send).and_return({
                                                                                              ts: 1
                                                                                            })
        expect { flow.execute }.to change { ServerIncident.count }.by(1)
      end

      it 'calls ChannelMessage#send with the right params only once' do
        FactoryBot.create(:application, :with_server, external_identifier: 'roadrunner.codelitt.dev',
                                                      environment: 'prod')

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
        FactoryBot.create(:application, :with_server, external_identifier: 'roadrunner.codelitt.dev', environment: 'qa')

        flow = described_class.new(incident_small_message)

        expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send).and_return({
                                                                                              ts: 1
                                                                                            })

        flow.run
      end
    end

    context 'when the slack_repository_info of the server repository has both the deploy channel and feed channel' do
      it 'sends a slack message to the feed channel' do
        application = FactoryBot.create(:application, :with_server, external_identifier: 'roadrunner.codelitt.dev',
                                                                    environment: 'prod')
        application.repository.slack_repository_info.update({
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
        application = FactoryBot.create(:application, :with_server, external_identifier: 'roadrunner.codelitt.dev',
                                                                    environment: 'prod')
        application.repository.slack_repository_info.update({
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

    context 'when there is a ignore type for the incident' do
      it 'it does not create a server incident ' do
        FactoryBot.create(:server, link: 'roadrunner.codelitt.dev')
        FactoryBot.create(:server_incident_type, name: 'Php File', regex_identifier: '.php.*')
        invalid_json = incident_small_message.deep_dup

        invalid_json[:event][:fields][:Message] =
          'ActionController::RoutingError (No route matches [GET] "/wp-content/plugins/wp-file-manager/lib/files/badmin1.php"):'

        flow = described_class.new(invalid_json)
        expect { flow.run }.to change { ServerIncident.count }.by(0)
      end
    end

    context 'when it is a dev server incident' do
      it 'it does not send server incident notification to slack' do
        application = FactoryBot.create(:application, :with_server, external_identifier: 'roadrunner.codelitt.dev',
                                                                    environment: 'dev')
        application.server.update(environment: 'dev')

        flow = described_class.new(incident_small_message)

        expect_any_instance_of(Clients::Slack::ChannelMessage).to_not receive(:send)

        expect { flow.run }.to change { ServerIncident.count }.by(1)
      end
    end
  end
end
