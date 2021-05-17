# frozen_string_literal: true

require 'rails_helper'
require 'external_api_helper'

RSpec.describe Clients::Azure::Release, type: :service do
  xdescribe '#list' do
    it 'returns a list of releases' do
      VCR.use_cassette('azure#release#list') do
        repository = FactoryBot.create(:repository, name: 'spaces')
        releases = described_class.new.list(repository)
        expect(releases.size).to eql(50)
      end
    end
  end

  describe '#create' do
    it 'creates a release parser' do
      VCR.use_cassette('azure#release#create') do
        repository = FactoryBot.create(:repository, name: 'ay-users-api-test')
        tag_name = 'rc.2.v1.0.0'
        release = described_class.new.create(repository, tag_name, 'master', '', true)

        expect(release.created_by).to eql('Kaio Magalhaes')
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
