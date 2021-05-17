# frozen_string_literal: true

require 'rails_helper'
require 'external_api_helper'
require 'flows_helper'

RSpec.describe Clients::Github::Parsers::RepositoryParser, type: :service do
  let(:valid_json) { load_fixture('github_repository.json') }
  let(:repository) { described_class.new(valid_json) }

  describe '#parser' do
    it 'returns a repository object' do
      expect(repository).not_to be_nil
    end

    it 'returns the name' do
      expect(repository.name).to eql('gh-hooks-repo-test')
    end
  end
end
