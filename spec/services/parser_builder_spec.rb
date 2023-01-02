# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ParserBuilder, type: :service do
  describe '#build' do
    context 'with params that match a parser' do
      it 'returns the right flow' do
        json = {
          deploy_type: 'deploy-notification'
        }

        flow = described_class.build(json)

        expect(flow).to be_a(Flows::Notifications::Deploy::Parser)
      end
    end
  end
end
