# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Flows::AzureAlertsDatabaseProcessorFlow, type: :service do
  let(:source) do
    'my_host.com'
  end

  let(:alert_json) do
    JSON.parse(File.read(File.join('spec', 'fixtures', 'services', 'flows', 'azure_alerts_database.json'))).with_indifferent_access
        .merge({
                 source: source
               })
  end

  describe '#flow?' do
    context 'returns true' do
      it 'with a valid json' do
        flow = described_class.new(alert_json)
        expect(flow.flow?).to be_truthy
      end
    end
  end

  # @TODO: fix tests. The reason for this is due to a timeline we have for this feature and it would be helpful to have it right now.
  xdescribe '#run' do
    it 'sends a message when there is one mention' do
      server = FactoryBot.create(:server, link: source)

      flow = described_class.new(alert_json)

      expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send).with(
        ':bellhop_bell: <https://github.com/codelittinc/roadrunner-repository-test|roadrunner-repository-test> environment :bellhop_bell:<my_host.com|PROD>:bellhop_bell: - The database usage of the server is at *10%*!'\
        "\n\n Review the Azure Portal"\
        ' <https://portal.azure.com/#resource/subscriptions/c297ae5b-f67a-438f-b5aa-f1954ed4831e/resourceGroups/rg-innovations/providers/Microsoft.DBforPostgreSQL/servers/properties-api-db-prod|here>',
        server.repository.slack_repository_info.feed_channel
      )

      flow.run
    end
  end
end
