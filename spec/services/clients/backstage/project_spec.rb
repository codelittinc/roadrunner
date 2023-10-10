# frozen_string_literal: true

require 'rails_helper'
require 'external_api_helper'

RSpec.describe Clients::Backstage::Project, type: :service do
  describe '#show' do
    context 'with a valid id' do
      it 'returns the project' do
        VCR.use_cassette('clients#backstage#project#show') do
          project = described_class.new.show('1')
          expect(project.name).to eq('Backstage')
        end
      end

      it 'returns the project wih a customer' do
        VCR.use_cassette('clients#backstage#project#show') do
          project = described_class.new.show('1')
          expect(project.customer.slack_api_key).to eq('123455')
        end
      end
    end
  end
end
