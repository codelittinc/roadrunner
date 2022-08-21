# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Flows::AppcenterDistributeNotificationFlow, type: :service do
  describe '#flow?' do
    context 'returns true' do
      before do
        repository = FactoryBot.create(:repository, name: 'pia-web-mobile')
        FactoryBot.create(:application, :with_server, repository:, external_identifier: 'pia.web.com')
      end

      it 'when deploy type is appcenter-distribute-notification' do
        flow = described_class.new({
                                     deploy_type: 'appcenter-distribute-notification',
                                     env: 'qa',
                                     host: 'pia.web.com'
                                   })
        expect(flow.flow?).to be_truthy
      end

      it 'when environment is not equals DEV' do
        flow = described_class.new({
                                     deploy_type: 'appcenter-distribute-notification',
                                     env: 'qa',
                                     host: 'pia.web.com'
                                   })
        expect(flow.flow?).to be_truthy
      end
    end

    context 'returns false' do
      it 'when deploy type is not appcenter-distribute-notification' do
        flow = described_class.new({
                                     deploy_type: 'not-appcenter-distribute-notification',
                                     env: 'qa',
                                     host: 'pia.web.com'
                                   })
        expect(flow.flow?).to be_falsey
      end

      it 'when environment is equals DEV' do
        flow = described_class.new({
                                     deploy_type: 'appcenter-distribute-notification',
                                     env: 'dev',
                                     host: 'pia.web.com'
                                   })
        expect(flow.flow?).to be_falsey
      end
    end
  end

  describe '#run' do
    context 'sends a channel message' do
      it 'when host is the application external identifier' do
        repository = FactoryBot.create(:repository, name: 'pia-web-mobile')
        FactoryBot.create(:application, :with_server, repository:, external_identifier: 'pia.web.com')

        flow = described_class.new({
                                     deploy_type: 'appcenter-distribute-notification',
                                     host: 'pia.web.com',
                                     env: 'prod',
                                     platform: 'Android',
                                     short_version: '1.0.42',
                                     version: '350',
                                     install_link: 'link_to_download'
                                   })

        expect_any_instance_of(Clients::Notifications::Channel).to receive(:send).with(
          'Distribution of *pia-web-mobile* to *PROD - Android* was finished with Success, version: <link_to_download|1.0.42(350)>',
          'feed-test-automations'
        )
        flow.run
      end
    end
  end
end
