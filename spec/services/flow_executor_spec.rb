# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FlowExecutor, type: :service do
  describe '#execute' do
    context 'when there is an exception' do
      it 'sends an exception message' do
        VCR.use_cassette('services#flowexecutor#handle-exception') do
          repository = FactoryBot.create(:repository)
          repository.slack_repository_info.update(deploy_channel: 'feed-test-automations')
          # branch from the json doesn't exist
          flow_request = FlowRequest.create!(json: {
            text: 'hotfix qa roadrunner-repository-test hotfix/test-hotfix-octtefdhh',
            channel_name: 'feed-test-automations',
            user_name: 'rheniery.mendes'
          }.to_json)
          flow_executor = described_class.new(flow_request)

          expected_message = 'There was an error with your request. Hey @automations-dev can you please check this?'
          allow_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send)
          allow_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send).with(expected_message,
                                                                                       'feed-test-automations')
          flow_executor.execute!
        end
      end
    end

    context 'when there is no results from flows and the command was sent through Channel' do
      it 'sends a channel no results message' do
        flow_request = FlowRequest.create!(json: {
          text: 'hotfix qa roadrunner-repository-test hotfix/test-hotfix-octtefdhh',
          channel_name: 'feed-test-automations',
          user_name: 'rheniery.mendes'
        }.to_json)
        flow_executor = described_class.new(flow_request)

        expected_message = 'There are no results for your request. Please, check for more information using the `/roadrunner help` command.'
        expect_any_instance_of(Clients::Slack::DirectMessage).to receive(:send).with(expected_message,
                                                                                     'rheniery.mendes')

        flow_executor.execute!
      end
    end
    context 'when there is no results from flows and the command was sent through Direct Message' do
      it 'sends a direct no results message' do
        flow_request = FlowRequest.create!(json: {
          text: 'test',
          user_name: 'rheniery.mendes'
        }.to_json)
        flow_executor = described_class.new(flow_request)

        expected_message = 'There are no results for your request. Please, check for more information using the `/roadrunner help` command.'
        expect_any_instance_of(Clients::Slack::DirectMessage).to receive(:send).with(expected_message,
                                                                                     'rheniery.mendes')

        flow_executor.execute!
      end
    end
  end
end
