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
        commits = described_class.new.commits(repository, 'main')
        expect(commits.size).to eql(4)
      end
    end
  end

  describe '#compare' do
    it 'returns a list the commits difference between two branches' do
      VCR.use_cassette('azure#branch#compare') do
        commits = described_class.new.compare(repository, 'main', 'feat/test')
        expect(commits.size).to eql(4)
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
