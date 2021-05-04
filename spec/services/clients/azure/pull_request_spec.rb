# frozen_string_literal: true

require 'rails_helper'
require 'external_api_helper'

RSpec.describe Clients::Azure::PullRequest, type: :service do
  describe '#list_commits' do
    it 'returns a list of commits' do
      VCR.use_cassette('azure#list_commits') do
        commits = described_class.new.list_commits('ay-users-api-test', 35)
        expect(commits.size).to eql(1)
      end
    end
  end
end
