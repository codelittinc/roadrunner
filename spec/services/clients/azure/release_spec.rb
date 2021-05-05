# frozen_string_literal: true

require 'rails_helper'
require 'external_api_helper'

RSpec.describe Clients::Azure::Release, type: :service do
  describe '#list' do
    it 'returns a list of releases' do
      VCR.use_cassette('azure#release#list') do
        commits = described_class.new.list
        expect(commits.size).to eql(50)
      end
    end
  end

  describe '#create' do
    it 'creates a release' do
      VCR.use_cassette('azure#release#create') do
        repo = 'ay-users-api-test'
        tag_name = 'v0.4.0'

        response = described_class.new.create(repo, tag_name, 'main', '', true)
        json_response = JSON.parse(response.body)
        json_response['name']

        expect(json_response['name']).to eql(tag_name)
      end
    end
  end
end
