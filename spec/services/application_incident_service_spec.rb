# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationIncidentService, type: :service do
  describe '#register_incident' do
    context 'when it is a dev server incident' do
      it 'it does not send server incident notification to slack' do
        repository = FactoryBot.create(:repository, name: 'pia-web-qa')
        server = FactoryBot.create(:application, external_identifier: 'codelitt.com', repository: repository, environment: 'dev')

        server_incident_service = described_class.new
        error_message = 'test'

        expect_any_instance_of(Clients::Slack::ChannelMessage).to_not receive(:send)

        expect { server_incident_service.register_incident!(server, error_message) }.to change { ServerIncident.count }.by(1)
      end
    end
  end
end
