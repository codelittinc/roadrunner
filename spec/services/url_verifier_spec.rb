# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UrlVerifier, type: :service do
  describe '.call' do
    context 'when the URL is valid' do
      let(:url) { 'https://example.com' }

      it 'returns the status on first try' do
        allow(Net::HTTP).to receive(:get_response).and_return(double(code: '200'))
        status = described_class.call(url, 0)
        expect(status.code).to eq('200')
      end

      it 'returns the status after retries' do
        call_count = 0
        allow(Net::HTTP).to receive(:get_response) do
          call_count += 1
          call_count < 3 ? double(code: '500') : double(code: '200')
        end
        status = described_class.call(url, 0)
        expect(status.code).to eq('200')
      end

      it 'returns the last status if all retries fail' do
        allow(Net::HTTP).to receive(:get_response).and_return(double(code: '500'))
        status = described_class.call(url, 0)
        expect(status.code).to eq('500')
      end
    end

    context 'when the URL is invalid' do
      let(:url) { 'invalid_url' }

      it 'returns nil' do
        status = described_class.call(url, 0)
        expect(status.code).to eq('-')
        expect(status.body).to eq('Unable to reach invalid_url after 3 attempts')
      end
    end
  end
end
