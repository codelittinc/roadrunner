# frozen_string_literal: true

require 'rails_helper'
require 'external_api_helper'

RSpec.describe Clients::Azure::Repository, type: :service do
  let(:repository) do
    FactoryBot.create(:repository, :avant)
  end

  describe '#get' do
    it 'returns a parse' do
      VCR.use_cassette('azure#repository#get_repository') do
        repo = described_class.new.get_repository(repository)

        expect(repo).to be_a(Clients::Azure::Parsers::RepositoryParser)
      end
    end

    it 'returns the correct repository' do
      VCR.use_cassette('azure#repository#get_repository') do
        repo = described_class.new.get_repository(repository)

        expect(repo.name).to eq('ay-users-api-test')
      end
    end
  end
end
