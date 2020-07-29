require 'rails_helper'

RSpec.describe Flows::DeployNotificationFlow, type: :service do
  describe '#flow?' do
    context 'returns true' do
      it 'when deploy type is deploy-notification' do
        flow = described_class.new({
                                     deploy_type: 'deploy-notification'
                                   })
        expect(flow.flow?).to be_truthy
      end
    end

    context 'returns false' do
      it 'when deploy type is not deploy-notification' do
        flow = described_class.new({
                                     deploy_type: 'not-deploy-notification'
                                   })
        expect(flow.flow?).to be_falsey
      end
    end
  end

  describe '#execute' do
    context 'sends a channel message' do
      it 'when host is the repository alias' do
        FactoryBot.create(:repository, alias: 'pia.mobile.android', name: 'Pia Mobile')

        flow = described_class.new({
                                     deploy_type: 'deploy-notification',
                                     host: 'pia.mobile.android',
                                     env: 'android'
                                   })

        expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send).with(
          'The deploy of the project *Pia Mobile* to *ANDROID* was finished with success!',
          'feed-test-automations'
        )
        flow.execute
      end

      it 'when host is the server partial link' do
        repository = FactoryBot.create(:repository, name: 'Pia Web')
        FactoryBot.create(:server, link: 'https://pia.web.com', repository: repository)

        flow = described_class.new({
                                     deploy_type: 'deploy-notification',
                                     host: 'pia.web.com',
                                     env: 'prod'
                                   })

        expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send).with(
          'The deploy of the project *Pia Web* to *PROD* was finished with success!',
          'feed-test-automations'
        )
        flow.execute
      end
    end
  end
end