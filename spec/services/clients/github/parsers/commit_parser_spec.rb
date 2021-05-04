# frozen_string_literal: true

require 'rails_helper'
require 'external_api_helper'

RSpec.describe Clients::Github::Parsers::CommitParser, type: :service do
  let(:valid_json) do
    JSON.parse(File.read(File.join('spec', 'fixtures', 'services', 'github_commit.json'))).with_indifferent_access
  end

  let(:commit) do
    described_class.new(valid_json)
  end
  describe '#parser' do
    it 'returns a commit object' do
      expect(commit).not_to be_nil
    end

    it 'returns the commit sha' do
      expect(commit.sha).to eql('95f822bdd339843a980c6eca4366d9f62a2db285')
    end

    it 'returns the commit author name' do
      expect(commit.author_name).to eql('Victor')
    end

    it 'returns the commit author email' do
      expect(commit.author_email).to eql('vcarvalho0402@gmail.com')
    end

    it 'returns the commit message' do
      expect(commit.message).to eql('Enable cors')
    end
  end
end
