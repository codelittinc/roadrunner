# frozen_string_literal: true

require 'rails_helper'
require 'external_api_helper'

RSpec.describe Clients::Github::Branch, type: :service do
  let(:repository) do
    FactoryBot.create(:repository, owner: 'codelittinc', name: 'test-gh-notifications')
  end

  describe '#commits' do
    it 'returns a list of commits' do
      VCR.use_cassette('github#branch#commits') do
        commits = described_class.new.commits(repository, 'master')
        expect(commits.size).to eql(30)
      end
    end
  end

  describe '#compare' do
    it 'returns a list the commits difference between two branches' do
      VCR.use_cassette('github#branch#compare') do
        commits = described_class.new.compare(repository, 'master', 'kaiomagalhaes-patch-111')
        expect(commits.size).to eql(2)
      end
    end
  end
end
