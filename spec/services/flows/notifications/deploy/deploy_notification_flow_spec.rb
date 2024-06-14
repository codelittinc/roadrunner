# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Flows::Notifications::Deploy::Flow, type: :service do
  describe '#flow?' do
    context 'returns true' do
      before do
        repository = FactoryBot.create(:repository, name: 'pia-web-mobile')
        FactoryBot.create(:application, :with_server, repository:, external_identifier: 'pia.web.com')
      end

      it 'when deploy type is deploy-notification' do
        flow = described_class.new({
                                     deploy_type: 'deploy-notification',
                                     env: 'qa',
                                     host: 'pia.web.com'
                                   })
        expect(flow.flow?).to be_truthy
      end

      it 'when environment is not equals DEV' do
        flow = described_class.new({
                                     deploy_type: 'deploy-notification',
                                     env: 'qa',
                                     host: 'pia.web.com'
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

  describe '#run' do
    context 'when given a custom message' do
      it 'sends it' do
        repository = FactoryBot.create(:repository, name: 'pia-web-mobile')
        FactoryBot.create(:application, :with_server, repository:, external_identifier: 'pia.web.com')

        custom_message = 'This is my custom message'
        flow = described_class.new({
                                     deploy_type: 'deploy-notification',
                                     host: 'pia.web.com',
                                     env: 'prod',
                                     custom_message:
                                   })

        expect_any_instance_of(Clients::Notifications::Channel).to receive(:send).with(
          custom_message,
          'feed-test-automations'
        )
        flow.run
      end
    end

    context 'sends a channel message' do
      it 'when host is the application external identifier' do
        repository = FactoryBot.create(:repository, name: 'pia-web-mobile')
        FactoryBot.create(:application, :with_server, repository:, external_identifier: 'pia.web.com')

        flow = described_class.new({
                                     deploy_type: 'deploy-notification',
                                     host: 'pia.web.com',
                                     env: 'prod'
                                   })

        expect_any_instance_of(Clients::Notifications::Channel).to receive(:send).with(
          'The deploy of *pia-web-mobile* to *PROD* was finished with the status: Success!',
          'feed-test-automations'
        )
        flow.run
      end

      it 'updated the latest release deploy status' do
        repository = FactoryBot.create(:repository, name: 'pia-web-mobile')
        application = FactoryBot.create(:application, :with_server, repository:,
                                                                    external_identifier: 'pia.web.com')
        release = FactoryBot.create(:release, application:, version: '3.0.0', deploy_status: nil)

        flow = described_class.new({
                                     deploy_type: 'deploy-notification',
                                     host: 'pia.web.com',
                                     env: 'prod'
                                   })

        expect_any_instance_of(Clients::Notifications::Channel).to receive(:send)
        flow.run

        release.reload

        expect(release.deploy_status).to eq('success')
      end
    end
  end
end
