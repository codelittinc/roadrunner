# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Flows::ServerIncidentUpdateFlow, type: :service do
  let(:valid_json) do
    JSON.parse(File.read(File.join('spec', 'fixtures', 'services', 'flows', 'server_incident_update.json'))).with_indifferent_access
  end

  describe '#flow?' do
    context 'returns true when' do
      it 'action is added-incident-update-reaction' do
        slack_message = FactoryBot.create(:slack_message, ts: '1598981604.000400', text: ':fire: <https://github.com/codelittinc/codelitt-v2|codelitt-v2> environment :fire:<https://codelitt.dev|>:fire: ```'\
            'Roadrunner is trying to reach https://codelitt.dev, and is receiving: code: 302 message: <!DOCTYPE html> <html> <head> <meta charset="UTF-```')
        application = FactoryBot.create(:application, external_identifier: 'codelitt-v2')
        FactoryBot.create(:server_incident, application: application, slack_message: slack_message)

        flow = described_class.new(valid_json)
        expect(flow.flow?).to be_truthy
      end

      it 'there is a slack message' do
        slack_message = FactoryBot.create(:slack_message, ts: '1598981604.000400', text: ':fire: <https://github.com/codelittinc/codelitt-v2|codelitt-v2> environment :fire:<https://codelitt.dev|>:fire: ```'\
            'Roadrunner is trying to reach https://codelitt.dev, and is receiving: code: 302 message: <!DOCTYPE html> <html> <head> <meta charset="UTF-```')
        application = FactoryBot.create(:application, external_identifier: 'codelitt-v2')
        FactoryBot.create(:server_incident, application: application, slack_message: slack_message)

        flow = described_class.new(valid_json)
        expect(flow.flow?).to be_truthy
      end

      it 'there is a server incident' do
        slack_message = FactoryBot.create(:slack_message, ts: '1598981604.000400', text: ':fire: <https://github.com/codelittinc/codelitt-v2|codelitt-v2> environment :fire:<https://codelitt.dev|>:fire: ```'\
            'Roadrunner is trying to reach https://codelitt.dev, and is receiving: code: 302 message: <!DOCTYPE html> <html> <head> <meta charset="UTF-```')
        application = FactoryBot.create(:application, external_identifier: 'codelitt-v2')
        FactoryBot.create(:server_incident, application: application, slack_message: slack_message)

        flow = described_class.new(valid_json)
        expect(flow.flow?).to be_truthy
      end

      it 'reaction is equals a white_check_mark' do
        slack_message = FactoryBot.create(:slack_message, ts: '1598981604.000400', text: ':fire: <https://github.com/codelittinc/codelitt-v2|codelitt-v2> environment :fire:<https://codelitt.dev|>:fire: ```'\
            'Roadrunner is trying to reach https://codelitt.dev, and is receiving: code: 302 message: <!DOCTYPE html> <html> <head> <meta charset="UTF-```')
        application = FactoryBot.create(:application, external_identifier: 'codelitt-v2')
        FactoryBot.create(:server_incident, application: application, slack_message: slack_message)

        flow = described_class.new(valid_json)
        expect(flow.flow?).to be_truthy
      end

      it 'reaction is equals a heavy_check_mark' do
        slack_message = FactoryBot.create(:slack_message, ts: '1598981604.000400', text: ':fire: <https://github.com/codelittinc/codelitt-v2|codelitt-v2> environment :fire:<https://codelitt.dev|>:fire: ```'\
            'Roadrunner is trying to reach https://codelitt.dev, and is receiving: code: 302 message: <!DOCTYPE html> <html> <head> <meta charset="UTF-```')
        application = FactoryBot.create(:application, external_identifier: 'codelitt-v2')
        FactoryBot.create(:server_incident, application: application, slack_message: slack_message)

        flow = described_class.new(valid_json)
        expect(flow.flow?).to be_truthy
      end
    end

    context 'returns false when' do
      it 'action is not added-incident-update-reaction or there is not a slack message' do
        flow = described_class.new(
          {
            action: 'test'
          }
        )
        expect(flow.flow?).to be_falsey
      end

      it 'there is no service incident' do
        FactoryBot.create(:slack_message, ts: '1598981604.000400', text: ':fire: <https://github.com/codelittinc/codelitt-v2|codelitt-v2> environment :fire:<https://codelitt.dev|>:fire: ```'\
            'Roadrunner is trying to reach https://codelitt.dev, and is receiving: code: 302 message: <!DOCTYPE html> <html> <head> <meta charset="UTF-```')
        flow = described_class.new(
          {
            action: 'added-incident-update-reaction',
            ts: '1598981604.000400'
          }
        )
        expect(flow.flow?).to be_falsey
      end

      it 'there is no reaction' do
        slack_message = FactoryBot.create(:slack_message, ts: '1598981604.000400', text: ':fire: <https://github.com/codelittinc/codelitt-v2|codelitt-v2> environment :fire:<https://codelitt.dev|>:fire: ```'\
            'Roadrunner is trying to reach https://codelitt.dev, and is receiving: code: 302 message: <!DOCTYPE html> <html> <head> <meta charset="UTF-```')
        application = FactoryBot.create(:application, external_identifier: 'codelitt-v2')
        FactoryBot.create(:server_incident, application: application, slack_message: slack_message)
        flow = described_class.new(
          {
            action: 'added-incident-update-reaction',
            channel: 'feed-test-automations',
            ts: '1598981604.000400'
          }
        )
        expect(flow.flow?).to be_falsey
      end

      it 'the reaction is different from white_check_mark or heavy_check_mark' do
        slack_message = FactoryBot.create(:slack_message, ts: '1598981604.000400', text: ':fire: <https://github.com/codelittinc/codelitt-v2|codelitt-v2> environment :fire:<https://codelitt.dev|>:fire: ```'\
            'Roadrunner is trying to reach https://codelitt.dev, and is receiving: code: 302 message: <!DOCTYPE html> <html> <head> <meta charset="UTF-```')
        application = FactoryBot.create(:application, external_identifier: 'codelitt-v2')
        FactoryBot.create(:server_incident, application: application, slack_message: slack_message)
        flow = described_class.new(
          {
            action: 'added-incident-update-reaction',
            channel: 'feed-test-automations',
            ts: '1598981604.000400',
            reactions: 'test'
          }
        )
        expect(flow.flow?).to be_falsey
      end

      it 'there is no action' do
        slack_message = FactoryBot.create(:slack_message, ts: '1598981604.000400', text: ':fire: <https://github.com/codelittinc/codelitt-v2|codelitt-v2> environment :fire:<https://codelitt.dev|>:fire: ```'\
            'Roadrunner is trying to reach https://codelitt.dev, and is receiving: code: 302 message: <!DOCTYPE html> <html> <head> <meta charset="UTF-```')
        application = FactoryBot.create(:application, external_identifier: 'codelitt-v2')
        FactoryBot.create(:server_incident, application: application, slack_message: slack_message)
        flow = described_class.new(
          {
            channel: 'feed-test-automations',
            ts: '1598981604.000400',
            reactions: 'white_check_mark'
          }
        )
        expect(flow.flow?).to be_falsey
      end
    end
  end

  describe '#run' do
    it 'update server incident to status white_check_mark' do
      slack_message = FactoryBot.create(:slack_message, ts: '1598981604.000400', text: ':fire: <https://github.com/codelittinc/codelitt-v2|codelitt-v2> environment :fire:<https://codelitt.dev|>:fire: ```'\
          'Roadrunner is trying to reach https://codelitt.dev, and is receiving: code: 302 message: <!DOCTYPE html> <html> <head> <meta charset="UTF-```')
      application = FactoryBot.create(:application, external_identifier: 'codelitt-v2')
      server_incident = FactoryBot.create(:server_incident, application: application, message: slack_message.text, slack_message: slack_message)

      flow = described_class.new(valid_json)

      expect { flow.run }.to change { server_incident.reload.state }.from('open').to('in_progress')
    end

    it 'update server incident to status heavy_check_mark' do
      slack_message = FactoryBot.create(:slack_message, ts: '1598981604.000400', text: ':fire: <https://github.com/codelittinc/codelitt-v2|codelitt-v2> environment :fire:<https://codelitt.dev|>:fire: ```'\
          'Roadrunner is trying to reach https://codelitt.dev, and is receiving: code: 302 message: <!DOCTYPE html> <html> <head> <meta charset="UTF-```')
      application = FactoryBot.create(:application, external_identifier: 'codelitt-v2')
      server_incident = FactoryBot.create(:server_incident, application: application, message: slack_message.text, slack_message: slack_message)

      valid_json_with_state_success = valid_json.deep_dup

      valid_json_with_state_success[:reaction] = 'heavy_check_mark'

      flow = described_class.new(valid_json_with_state_success)

      expect { flow.run }.to change { server_incident.reload.state }.from('open').to('completed')
    end
  end
end
