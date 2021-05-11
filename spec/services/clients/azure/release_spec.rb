# frozen_string_literal: true

require 'rails_helper'
require 'external_api_helper'

RSpec.describe Clients::Azure::Release, type: :service do
  describe '#list' do
    it 'returns a list of releases' do
      VCR.use_cassette('azure#release#list') do
        releases = described_class.new.list('spaces')
        expect(releases.size).to eql(50)
      end
    end
  end

  describe '#create' do
    it 'creates a release parser' do
      VCR.use_cassette('azure#release#create') do
        repo = 'ay-users-api-test'
        tag_name = 'v0.4.0'
        release = described_class.new.create(repo, tag_name, 'main', '', true)

        expect(release).to be_a(Clients::Azure::Parsers::ReleaseParser)
      end
    end
  end
end
