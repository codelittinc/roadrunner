# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Flows::GraylogsIncidentNotificationUpdateFlow, type: :service do
  describe '#flow?' do
    context 'with a valid action' do
      it 'returns true' do
        FactoryBot.create(:slack_message, ts: '123',
                                          text: ':droplet: ay-excel-import-api environment :droplet:QA:droplet:')
        flow = described_class.new({
                                     action: 'user-addressing-error',
                                     ts: '123'
                                   })

        expect(flow.flow?).to be_truthy
      end
    end

    context 'with an invalid action' do
      it 'returns false' do
        FactoryBot.create(:slack_message, ts: '123')
        flow = described_class.new({
                                     action: 'no-action',
                                     ts: '123'
                                   })

        expect(flow.flow?).to be_falsey
      end
    end

    context 'with a valid ts' do
      it 'returns true' do
        FactoryBot.create(:slack_message, ts: '123',
                                          text: ':droplet: ay-excel-import-api environment :droplet:QA:droplet:')
        flow = described_class.new({
                                     action: 'user-addressing-error',
                                     ts: '123'
                                   })

        expect(flow.flow?).to be_truthy
      end
    end

    context 'with an invalid ts' do
      it 'returns false' do
        flow = described_class.new({
                                     action: 'no-action',
                                     ts: '123'
                                   })

        expect(flow.flow?).to be_falsey
      end
    end
  end

  describe '#execute' do
    it 'creates a set of commits from the pull request in the database' do
      timestamp = '123'
      channel = 'test-channel'

      FactoryBot.create(:slack_message,
                        ts: timestamp,
                        text: ':droplet: ay-excel-import-api environment :droplet:QA:droplet:')

      flow = described_class.new({
                                   action: 'user-addressing-error',
                                   ts: timestamp,
                                   username: 'kaiomagalhaes',
                                   channel:
                                 })

      new_message = ':fire_engine: ay-excel-import-api environment :fire_engine:QA:fire_engine: - reviewed by @kaiomagalhaes'
      expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:update).with(
        new_message,
        channel,
        timestamp
      )

      flow.execute
    end
  end
end
