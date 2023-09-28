# frozen_string_literal: true

require 'rails_helper'
require 'external_api_helper'

RSpec.describe Clients::Backstage::Customer, type: :service do
  describe '#get' do
    context 'with a valid id' do
      it 'returns a Customer model' do
        VCR.use_cassette('clients#backstage#customer') do
          customer = described_class.new.get(1)
          expect(customer).to be_a(Customer)
        end
      end
    end
  end
end
