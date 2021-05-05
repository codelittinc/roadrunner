# frozen_string_literal: true

require 'rails_helper'
require 'external_api_helper'

RSpec.describe Clients::Azure::Parsers::CommitParser, type: :service do
  let(:valid_json) do
    JSON.parse(File.read(File.join('spec', 'fixtures', 'services', 'azure_commit.json'))).with_indifferent_access
  end

  let(:commit) do
    described_class.new(valid_json)
  end
  describe '#parser' do
    it 'returns a commit object' do
      expect(commit).not_to be_nil
    end

    it 'returns the commit sha' do
      expect(commit.sha).to eql('82d4cf31a948ca3f7bfb2c6bb1286badc0a1013d')
    end

    it 'returns the commit author name' do
      expect(commit.author_name).to eql('Kaio Magalhaes')
    end

    it 'returns the commit author email' do
      expect(commit.author_email).to eql('kaio.magalhaes@avisonyoung.onmicrosoft.com')
    end

    it 'returns the commit message' do
      expect(commit.message).to eql('Added test')
    end
  end
end
