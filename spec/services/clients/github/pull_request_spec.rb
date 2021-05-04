# frozen_string_literal: true

require 'rails_helper'
require 'external_api_helper'

RSpec.describe Clients::Github::PullRequest, type: :service do
  describe '#list_commits' do
    let(:repository) do
      FactoryBot.create(:repository, owner: 'codelittinc', name: 'roadrunner-rails')
    end

    it 'returns a list of commits' do
      VCR.use_cassette('github#list_commits') do
        commits = described_class.new.list_commits(repository, 13)
        expect(commits.size).to eql(1)
      end
    end

    it 'returns a list of parsed commits' do
      VCR.use_cassette('github#list_commits') do
        commits = described_class.new.list_commits(repository, 13)
        commit = commits.first

        expect(commit).to be_a(Clients::Github::Parsers::CommitParser)
      end
    end
  end
end
