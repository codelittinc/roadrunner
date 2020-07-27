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
        FactoryBot.create(:server, link: 'roadrunner.codelitt.dev')

        flow = described_class.new(incident_big_message)
        expect(flow.flow?).to be_truthy
      end
    end

    context 'when event_definition_title does not exist' do
      it 'returns false' do
        FactoryBot.create(:server, link: 'roadrunner.codelitt.dev')
        flow = described_class.new({
                                     event_definition_title: nil
                                   })
        expect(flow.flow?).to be_falsey
      end
    end

    context 'when the source exists' do
      it 'returns true' do
        FactoryBot.create(:server, link: 'roadrunner.codelitt.dev')
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
end
