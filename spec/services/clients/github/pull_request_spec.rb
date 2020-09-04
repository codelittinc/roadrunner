# frozen_string_literal: true

require 'rails_helper'
require 'external_api_helper'

RSpec.describe Clients::Github::PullRequest, type: :service do
  describe '#list_commits' do
    it 'returns a list of commits' do
      VCR.use_cassette('github#list_commits') do
        commits = described_class.new.list_commits('codelittinc/roadrunner-rails', 13)
        expect(commits.size).to eql(1)
      end
    end
  end
end
