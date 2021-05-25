# frozen_string_literal: true

require 'rails_helper'
require 'external_api_helper'

RSpec.describe Clients::Azure::Branch, type: :service do
  let(:repository) do
    FactoryBot.create(:repository, name: 'ay-users-api-test')
  end

  describe '#commits' do
    it 'returns a list of commits' do
      VCR.use_cassette('azure#branch#commits') do
        commits = described_class.new.commits(repository, 'master')
        expect(commits.size).to eql(14)
      end
    end
  end

  describe '#compare' do
    it 'returns the correct commits between two branches' do
      repository = FactoryBot.create(:repository, name: 'roadrunner-repository-test')
      VCR.use_cassette('azure#branch#compare') do
        commits = described_class.new.compare(repository, 'master', 'feat/test-compare-branches')
        expected_commits_sha = %w[
          cc6c48dae95743d3dbcdbf8c58dc4bf6c8ee120f
          8773fb97bbbeee26a0b0a70a6ddecc39bc1226c9
          94047697dd6287f851d26ebf7236f128735e81c3
        ]
        expect(commits.map(&:sha)).to eql(expected_commits_sha)
      end
    end

    it 'returns the correct commits between two tags' do
      repository = FactoryBot.create(:repository, name: 'roadrunner-repository-test')
      VCR.use_cassette('azure#branch#compare') do
        commits = described_class.new.compare(repository, 'rc.1.v1.1.0', 'v1.0.0')
        expected_commits_sha = %w[
          cc6c48dae95743d3dbcdbf8c58dc4bf6c8ee120f
          8773fb97bbbeee26a0b0a70a6ddecc39bc1226c9
          94047697dd6287f851d26ebf7236f128735e81c3
          5964d2ba6159d6c0cdc7c5241f59f4a6d7d8dd3e
        ]
        expect(commits.map(&:sha)).to eql(expected_commits_sha)
      end
    end
  end

  describe '#branch_exists' do
    it 'returns true when the branch exists' do
      VCR.use_cassette('azure#branch#branch_exists_true') do
        exists = described_class.new.branch_exists?(repository, 'roadrunner/test')
        expect(exists).to be_truthy
      end
    end

    it 'returns true when the branch exists' do
      VCR.use_cassette('azure#branch#branch_exists_false') do
        exists = described_class.new.branch_exists?(repository, 'roadrunner/test1234')
        expect(exists).to be_falsey
      end
    end
  end
end
