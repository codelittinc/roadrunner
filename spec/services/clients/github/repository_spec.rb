# frozen_string_literal: true

require 'rails_helper'
require 'external_api_helper'

RSpec.describe Clients::Github::Repository, type: :service do
  let(:repository) do
    FactoryBot.create(:repository, owner: 'codelittinc', name: 'gh-hooks-repo-test')
  end

  describe '#get' do
    it 'returns a repo' do
      VCR.use_cassette('github#repository#get') do
        repo = described_class.new.get_repository(repository)

        expect(repo).to be_a(Clients::Github::Parsers::RepositoryParser)
      end
    end
  end
end
