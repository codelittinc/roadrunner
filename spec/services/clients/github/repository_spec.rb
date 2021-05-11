# frozen_string_literal: true

require 'rails_helper'
require 'external_api_helper'

RSpec.describe Clients::Github::Repository, type: :service do
  describe '#get' do
    it 'returns a repo' do
      VCR.use_cassette('github#repository#get') do
        repo = 'codelittinc/gh-hooks-repo-test'

        repository = described_class.new.get_repository(repo)

        expect(repository).to be_a(Clients::Github::Parsers::RepositoryParser)
      end
    end
  end
end
