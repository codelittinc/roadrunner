# frozen_string_literal: true

require 'rails_helper'
require 'external_api_helper'

RSpec.describe Clients::Azure::Branch, type: :service do
  describe '#commits' do
    it 'returns a list of commits' do
      VCR.use_cassette('azure#branch#commits') do
        commits = described_class.new.commits('ay-users-api-test', 'main')
        expect(commits.size).to eql(4)
      end
    end
  end
end
