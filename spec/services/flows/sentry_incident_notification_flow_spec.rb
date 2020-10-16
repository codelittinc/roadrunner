# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Flows::SentryIncidentNotificationFlow, type: :service do
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
      repository = FactoryBot.create(:repository, name: 'pia-web-qa')
      server = FactoryBot.create(:server, external_identifier: 'pia-web-qa', repository: repository)

      flow = described_class.new(valid_incident)
      expect_any_instance_of(ServerIncidentService).to receive(:register_incident!).with(
        server,
        "\n *_Error: This shouldn't happen!_*\n *File Name*: /static/js/27.chunk.js\n *Function*: onClickSuggestion\n *User*: \n>Id - 9\n>Email - victor.carvalho@codelitt.com\n *Browser*: Chrome\n\n "\
        '*Link*: <https://sentry.io/organizations/codelitt-7y/issues/1851228751/events/6e54db70e36142d4b300b3389f4ff238/?project=5388450|See issue in Sentry.io>',
        nil,
        'sentry'
      )

      flow.run
    end

    it 'update server incident and create server incident instance' do
      repository = FactoryBot.create(:repository, name: 'pia-web-qa')
      server = FactoryBot.create(:server, external_identifier: 'pia-web-qa', repository: repository)
      slack_message = FactoryBot.create(:slack_message, ts: '1598981604.000400', text: "\n *_Error: This shouldn't happen!_*\n *File Name*: /static/js/27.chunk.js\n *Function*: onClickSuggestion\n *User*: \n>Id - 9"\
              "\n>Email - victor.carvalho@codelitt.com\n *Browser*: Chrome\n\n *Link*: <https://sentry.io/organizations/codelitt-7y/issues/1851228751/events/6e54db70e36142d4b300b3389f4ff238/?project=5388450|See issue "\
              'in Sentry.io>')

      FactoryBot.create(:server_incident, server: server, message: slack_message.text, slack_message: slack_message)

      flow = described_class.new(valid_incident)

      expect { flow.run }.to change { ServerIncidentInstance.count }.by(1)
    end

    context 'when there is a ignore type for the incident' do
      it 'it does not create a server incident ' do
        FactoryBot.create(:server, link: 'roadrunner.codelitt.dev', name: 'test')
        FactoryBot.create(:server_incident_type, name: 'Php File', regex_identifier: '.php.*')
        invalid_json = valid_incident.deep_dup

        invalid_json[:event][:title] = 'ActionController::RoutingError (No route matches [GET] "/wp-content/plugins/wp-file-manager/lib/files/badmin1.php"):'

        flow = described_class.new(invalid_json)
        expect { flow.run }.to change { ServerIncident.count }.by(0)
      end
    end
  end
end
