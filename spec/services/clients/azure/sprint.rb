# frozen_string_literal: true

require 'rails_helper'
require 'external_api_helper'

RSpec.describe Clients::Azure::Sprint, type: :service do
  describe '#list' do
    it 'returns a list of sprints' do
      VCR.use_cassette('azure#sprint#list') do
        sprints = described_class.new.list('Visualization')
        expect(sprints.size).to eql(11)
      end
    end

    it 'returns a list of sprint objects' do
      VCR.use_cassette('azure#sprint#list') do
        sprints = described_class.new.list('Visualization')
        expect(sprints.first).to be_a(Clients::Azure::Parsers::SprintParser)
      end
    end
  end
end
