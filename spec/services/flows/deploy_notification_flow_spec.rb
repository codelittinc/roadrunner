# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Flows::DeployNotificationFlow, type: :service do
  describe '#flow?' do
    context 'returns true' do
      it 'when deploy type is deploy-notification' do
        flow = described_class.new({
                                     deploy_type: 'deploy-notification',
                                     env: 'qa'
                                   })
        expect(flow.flow?).to be_truthy
      end

      it 'when environment is not equals DEV' do
        flow = described_class.new({
                                     deploy_type: 'deploy-notification',
                                     env: 'qa'
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

      it 'when environment is equals dev' do
        flow = described_class.new({
                                     deploy_type: 'deploy-notification',
                                     env: 'dev'
                                   })
        expect(flow.flow?).to be_falsey
      end
    end
  end

  describe '#execute' do
    context 'sends a channel message' do
      xit 'when host is the repository alias' do
        FactoryBot.create(:repository, alias: 'pia.mobile.android', name: 'Pia Mobile')

        flow = described_class.new({
                                     deploy_type: 'deploy-notification',
                                     host: 'pia.mobile.android',
                                     env: 'qa',
                                     type: 'android',
                                     status: 'success'
                                   })

        expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send).with(
          'The deploy of *Pia Mobile* to *QA - ANDROID* was finished with the status: Success!',
          'feed-test-automations'
        )

        flow.execute
      end

      it 'when host is the server partial link' do
        repository = FactoryBot.create(:repository, name: 'Pia Web')
        application = FactoryBot.create(:application, :with_server, repository: repository, external_identifier: 'pia.web.com')
        application.server.update(link: 'https://pia.web.com')

        flow = described_class.new({
                                     deploy_type: 'deploy-notification',
                                     host: 'pia.web.com',
                                     env: 'prod'
                                   })

        expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send).with(
          'The deploy of *Pia Web* to *PROD* was finished with the status: Success!',
          'feed-test-automations'
        )
        flow.execute
      end
    end
  end
end
