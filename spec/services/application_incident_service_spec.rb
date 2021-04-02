# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationIncidentService, type: :service do
  let(:repository) { FactoryBot.create(:repository, name: 'codelitt-v2') }

  describe '#register_incident' do
    context 'when the environment is qa or prod' do
      it 'sends a correct message to the channel' do
        application = FactoryBot.create(:application, :with_server, external_identifier: 'codelitt.com', repository: repository, environment: 'prod')

        server_incident_service = described_class.new
        error_message = 'we did not start the fire'

        expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send).with(
          ":fire: <https://github.com/codelittinc/codelitt-v2|codelitt-v2> environment :fire:<roadrunner.codelitt.dev|PROD>:fire: \n "\
          '```we did not start the fire```',
          'feed-test-automations'
        ).and_return({ ts: 1 })

        server_incident_service.register_incident!(application, error_message)
      end

      it 'creates a new ServerIncident record' do
        application = FactoryBot.create(:application, :with_server, external_identifier: 'codelitt.com', repository: repository, environment: 'qa')

        server_incident_service = described_class.new
        error_message = 'test'

        expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send).and_return({ ts: 1 })

        expect { server_incident_service.register_incident!(application, error_message) }.to change { ServerIncident.count }.by(1)
      end

      it 'sends multiple messages to the channel when it has more than 150 characters' do
        application = FactoryBot.create(:application, :with_server, external_identifier: 'codelitt.com', repository: repository, environment: 'prod')

        server_incident_service = described_class.new
        first_half = 'a' * 150
        second_half = 'b' * 150
        error_message = "#{first_half}#{second_half}"

        receive_count = 0
        allow_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send) { receive_count += 1 }.and_return({ ts: 1 })
        server_incident_service.register_incident!(application, error_message)

        expect(receive_count).to be > 0
      end
    end

    context 'when it is a dev server incident' do
      it 'it does not send server incident notification to slack' do
        application = FactoryBot.create(:application, external_identifier: 'codelitt.com', repository: repository, environment: 'dev')

        server_incident_service = described_class.new
        error_message = 'test'

        expect_any_instance_of(Clients::Slack::ChannelMessage).to_not receive(:send)

        expect { server_incident_service.register_incident!(application, error_message) }.to change { ServerIncident.count }.by(1)
      end
    end
  end
end
