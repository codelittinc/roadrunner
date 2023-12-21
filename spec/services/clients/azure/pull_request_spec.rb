# frozen_string_literal: true

require 'rails_helper'
require 'external_api_helper'

RSpec.describe Clients::Azure::PullRequest, type: :service do
  include_context 'mock backstage azure'

  describe '#list_commits' do
    let(:repository) do
      FactoryBot.create(:repository, owner: 'Avant', name: 'ay-users-api-test')
    end

    it 'returns a list of commits' do
      VCR.use_cassette('azure#list_commits') do
        commits = described_class.new.list_commits(repository, 35)
        expect(commits.size).to eql(1)
      end
    end

    it 'returns a list of parsed commits' do
      VCR.use_cassette('azure#list_commits') do
        commits = described_class.new.list_commits(repository, 35)
        commit = commits.first

        expect(commit).to be_a(Clients::Azure::Parsers::CommitParser)
      end
    end
  end
end
