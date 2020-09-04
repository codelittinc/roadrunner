# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Flows::SentryErrorNotificationFlow, type: :service do
  let(:valid_incident) do
    JSON.parse(File.read(File.join('spec', 'fixtures', 'services', 'flows', 'sentry_incident.json'))).with_indifferent_access
  end

  let(:invalid_incident) do
    JSON.parse(File.read(File.join('spec', 'fixtures', 'services', 'flows', 'graylogs_incident_big_message.json'))).with_indifferent_access
  end

  describe '#flow?' do
    context 'returns true' do
      it 'with a valid json' do
        FactoryBot.create(:server, external_identifier: 'pia-web-qa')
        flow = described_class.new(valid_incident)
        expect(flow.flow?).to be_truthy
      end

      it 'when there is a server with an external_identifier with the same project_name' do
        FactoryBot.create(:server, external_identifier: 'pia-web-qa')
        flow = described_class.new(valid_incident)
        expect(flow.flow?).to be_truthy
      end
    end

    context 'returns false' do
      it 'with a invalid json' do
        FactoryBot.create(:server, external_identifier: 'pia-web-qa')
        flow = described_class.new(invalid_incident)
        expect(flow.flow?).to be_falsey
      end

      it 'when there no server with an external identifier with the same project_name' do
        flow = described_class.new(valid_incident)
        expect(flow.flow?).to be_falsey
      end
    end
  end

  describe '#run' do
    it 'calls the ServerIncidentService with the right params' do
      server = FactoryBot.create(:server, external_identifier: 'pia-web-qa')

      flow = described_class.new(valid_incident)
      expect_any_instance_of(ServerIncidentService).to receive(:register_incident!).with(
        server,
        "Error: This shouldn't happen!"
      )

      flow.run
    end
  end
end
