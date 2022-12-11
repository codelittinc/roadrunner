# frozen_string_literal: true

require 'rails_helper'
require 'external_api_helper'

RSpec.describe Clients::Notifications::Direct, type: :service do
  describe '#send' do
    context 'the username is invalid when' do
      it 'has less than 3 characters' do
        expect(SimpleRequest).to_not receive(:post)

        described_class.new.send('message', 'ab', false)
      end

      it 'is nil' do
        expect(SimpleRequest).to_not receive(:post)

        described_class.new.send('message', nil, false)
      end
    end

    context 'the username is valid when' do
      it 'has 3 or more characters' do
        expect(SimpleRequest).to receive(:post)

        described_class.new.send('message', 'abc', false)
      end
    end
  end
end
