# frozen_string_literal: true

require 'rails_helper'
require 'external_api_helper'

RSpec.describe Flows::ListChannelRepositoriesFlow, type: :service do
  let(:valid_json) do
    JSON.parse(File.read(File.join('spec', 'fixtures', 'services', 'flows',
                                   'list_repositories.json'))).with_indifferent_access
  end

  describe '#flow?' do
    context 'returns true' do
      it 'when the json is valid' do
        FactoryBot.create(:repository)

        flow = described_class.new(valid_json)
        expect(flow.flow?).to be_truthy
      end
    end

    context 'returns false' do
      it 'when the text is not present' do
        FactoryBot.create(:repository)

        flow = described_class.new({
                                     channel_name: 'feed-test-automations',
                                     user_name: 'kaio.magalhaes'
                                   })

        expect(flow.flow?).to be_falsey
      end

      it "when the text is different from 'list repositories'" do
        FactoryBot.create(:repository)

        flow = described_class.new({
                                     text: 'do not list repositories',
                                     channel_name: 'feed-test-automations',
                                     user_name: 'kaio.magalhaes'
                                   })

        expect(flow.flow?).to be_falsey
      end
    end
  end

  describe '#execute' do
    context 'sends a slack message to the user when' do
      it 'there is one repository' do
        FactoryBot.create(:repository)

        flow = described_class.new({
                                     text: 'list repositories',
                                     channel_name: 'feed-test-automations',
                                     user_name: 'kaio.magalhaes'
                                   })

        expect_any_instance_of(Clients::Slack::DirectMessage).to receive(:send).with(
          "You can deploy the following repositories on the channel: *feed-test-automations*\n - roadrunner-repository-test",
          'kaio.magalhaes'
        )

        flow.execute
      end

      it 'there are multiple repositories ' do
        FactoryBot.create(:repository)
        FactoryBot.create(:repository, name: 'roadrunner-rails')

        flow = described_class.new({
                                     text: 'list repositories',
                                     channel_name: 'feed-test-automations',
                                     user_name: 'kaio.magalhaes'
                                   })

        expect_any_instance_of(Clients::Slack::DirectMessage).to receive(:send).with(
          "You can deploy the following repositories on the channel: *feed-test-automations*\n - roadrunner-repository-test\n - roadrunner-rails",
          'kaio.magalhaes'
        )

        flow.execute
      end
    end
  end
end
