# frozen_string_literal: true

require 'rails_helper'
# require 'external_api_helper'

RSpec.describe Flows::Notifications::Incident::DatadogRegister::Flow, type: :service do
  let(:datadog_incident_message) do
    JSON.parse(File.read(File.join('spec', 'fixtures', 'services', 'flows',
                                   'datadog_incident_notification_flow_spec.json'))).with_indifferent_access
  end

  describe '#can_execute?' do
    context 'when application, event_type and origin exist' do
      it 'returns true' do
        FactoryBot.create(:application, :with_server, external_identifier: 'datadog::roadrunner.codelitt.dev')

        flow = described_class.new({
                                     event_type: 'error_tracking_alert',
                                     origin: 'datadog',
                                     event_message: '[[key::project::roadrunner.codelitt.dev]]'
                                   })
        expect(flow.can_execute?).to be_truthy
      end
    end

    context 'when application does not exist' do
      it 'returns false' do
        FactoryBot.create(:application, :with_server, external_identifier: 'datadog::roadrunner.codelitt.dev')

        flow = described_class.new({
                                     event_type: 'error_tracking_alert',
                                     origin: 'datadog',
                                     event_message: '[[key::project::random-project]]'
                                   })

        expect(flow.can_execute?).to be_falsey
      end
    end

    context 'when origin is not from datadog' do
      it 'returns false' do
        FactoryBot.create(:application, :with_server, external_identifier: 'datadog::roadrunner.codelitt.dev')

        flow = described_class.new({
                                     event_type: 'error_tracking_alert',
                                     origin: 'datadog-random-text',
                                     event_message: '[[key::project::roadrunner.codelitt.dev]]'
                                   })

        expect(flow.can_execute?).to be_falsey
      end
    end

    context 'when event_type is neither error_tracking_alert or alert_tracking_alert' do
      it 'returns false' do
        FactoryBot.create(:application, :with_server, external_identifier: 'datadog::roadrunner.codelitt.dev')

        flow = described_class.new({
                                     event_type: 'info_tracking_alert',
                                     origin: 'datadog',
                                     event_message: '[[key::project::roadrunner.codelitt.dev]]'
                                   })

        expect(flow.can_execute?).to be_falsey
      end
    end
  end

  describe '#run' do
    context 'with a valid json' do
      it 'creates a new ServerIncident record' do
        FactoryBot.create(:application, :with_server, external_identifier: 'datadog::roadrunner.codelitt.dev',
                                                      environment: 'qa')

        flow = described_class.new(datadog_incident_message)
        expect_any_instance_of(Clients::Notifications::Channel).to receive(:send).and_return({
                                                                                               ts: 1
                                                                                             })
        expect { flow.run }.to change { ServerIncident.count }.by(1)
      end

      it 'calls Channel#send with the right params only once' do
        FactoryBot.create(:application, :with_server, external_identifier: 'datadog::roadrunner.codelitt.dev',
                                                      environment: 'prod')

        flow = described_class.new(datadog_incident_message)
        expect_any_instance_of(Clients::Notifications::Channel).to receive(:send).with(
          ":fire: <https://github.com/codelittinc/roadrunner-repository-test|roadrunner-repository-test> environment :fire:<roadrunner.codelitt.dev|PROD>:fire: \n Service: prod-roadrunner\n- Component: redis\n" \
          "- Env: prod\n- Error Url:;[[key::project::roadrunner.codelitt.dev]]",
          'feed-test-automations'
        ).and_return({
                       ts: 1
                     })
        flow.run
      end
    end

    context 'when no slack message was send 10 minutes before' do
      it 'sends a slack message' do
        FactoryBot.create(:application, :with_server, external_identifier: 'datadog::roadrunner.codelitt.dev',
                                                      environment: 'qa')

        flow = described_class.new(datadog_incident_message)

        expect_any_instance_of(Clients::Notifications::Channel).to receive(:send).and_return({
                                                                                               ts: 1
                                                                                             })

        flow.run
      end
    end

    context 'when the slack_repository_info of the server repository has both the deploy channel and feed channel' do
      it 'sends a slack message to the feed channel' do
        application = FactoryBot.create(:application, :with_server, external_identifier: 'datadog::roadrunner.codelitt.dev',
                                                                    environment: 'prod')
        application.repository.slack_repository_info.update({
                                                              feed_channel: 'my-cool-feed-repository-channel',
                                                              deploy_channel: 'deploy-channel'
                                                            })

        flow = described_class.new(datadog_incident_message)

        expect_any_instance_of(Clients::Notifications::Channel).to receive(:send).with(
          ":fire: <https://github.com/codelittinc/roadrunner-repository-test|roadrunner-repository-test> environment :fire:<roadrunner.codelitt.dev|PROD>:fire: \n Service: prod-roadrunner\n- Component: redis\n" \
          "- Env: prod\n- Error Url:;[[key::project::roadrunner.codelitt.dev]]",
          'my-cool-feed-repository-channel'
        ).and_return({
                       ts: 1
                     })

        flow.run
      end
    end

    context 'when the slack_repository_info of the server repository has only the deploy channel' do
      it 'sends a slack message to the feed channel' do
        application = FactoryBot.create(:application, :with_server, external_identifier: 'datadog::roadrunner.codelitt.dev',
                                                                    environment: 'prod')
        application.repository.slack_repository_info.update({
                                                              feed_channel: nil,
                                                              deploy_channel: 'deploy-channel'
                                                            })

        flow = described_class.new(datadog_incident_message)

        expect_any_instance_of(Clients::Notifications::Channel).to receive(:send).with(
          ":fire: <https://github.com/codelittinc/roadrunner-repository-test|roadrunner-repository-test> environment :fire:<roadrunner.codelitt.dev|PROD>:fire: \n Service: prod-roadrunner\n- Component: redis\n" \
          "- Env: prod\n- Error Url:;[[key::project::roadrunner.codelitt.dev]]",
          'deploy-channel'
        ).and_return({
                       ts: 1
                     })

        flow.run
      end
    end
  end
end
