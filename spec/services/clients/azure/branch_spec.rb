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

  describe '#compare' do
    it 'returns a list the commits difference between two branches' do
      VCR.use_cassette('azure#branch#compare') do
        commits = described_class.new.compare('ay-users-api-test', 'main', 'feat/test')
        expect(commits.size).to eql(4)
      end
    end
  end

  describe '#branch_exists' do
    it 'returns true when the branch exists' do
      VCR.use_cassette('azure#branch#branch_exists_true') do
        exists = described_class.new.branch_exists?('ay-users-api-test', 'roadrunner/test')
        expect(exists).to be_truthy
      end
    end

    it 'returns true when the branch exists' do
      VCR.use_cassette('azure#branch#branch_exists_false') do
        exists = described_class.new.branch_exists?('ay-users-api-test', 'roadrunner/test1234')
        expect(exists).to be_falsey
      end
    end
  end
end
