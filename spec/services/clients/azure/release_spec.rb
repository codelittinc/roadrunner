# frozen_string_literal: true

require 'rails_helper'
require 'external_api_helper'

RSpec.describe Clients::Azure::Release, type: :service do
  describe '#list' do
    it 'returns a list of releases' do
      VCR.use_cassette('azure#release#list') do
        repository = FactoryBot.create(:repository, name: 'ay-users-api-test')
        releases = described_class.new.list(repository)
        expect(releases.size).to eql(14)
      end
    end

    it 'returns the correct information' do
      VCR.use_cassette('azure#release#list') do
        repository = FactoryBot.create(:repository, name: 'ay-users-api-test')
        releases = described_class.new.list(repository)
        expect(releases.first.tag_name).to eq('v1.2.0')
      end
    end

    it 'returns the releases in the correct order' do
      VCR.use_cassette('azure#release#list-order') do
        repository = FactoryBot.create(:repository, name: 'ay-users-api-test')
        releases = described_class.new.list(repository)
        expect(releases.first.tag_name).to eq('v1.2.0')
      end
    end
  end

  describe '#create' do
    it 'creates a release parser, with correct created_by' do
      VCR.use_cassette('azure#release#create') do
        repository = FactoryBot.create(:repository, name: 'ay-users-api-test')
        tag_name = 'v1.3.0'
        release = described_class.new.create(repository, tag_name, 'master', '', true)

        expect(release.created_by).to eql('Kaio Magalhaes')
      end
    end

    it 'creates a release parser, with correct tag_name' do
      VCR.use_cassette('azure#release#create') do
        repository = FactoryBot.create(:repository, name: 'ay-users-api-test')
        tag_name = 'rc.2.v1.0.0'
        release = described_class.new.create(repository, tag_name, 'master', '', true)

        expect(release.tag_name).to eql('v1.3.0')
      end
    end

    it 'returns a release parser' do
      VCR.use_cassette('azure#release#create') do
        repository = FactoryBot.create(:repository, name: 'ay-users-api-test')
        tag_name = 'rc.2.v1.0.0'
        release = described_class.new.create(repository, tag_name, 'master', '', true)

        expect(release).to be_a(Clients::Azure::Parsers::ReleaseParser)
      end
    end
  end
end
