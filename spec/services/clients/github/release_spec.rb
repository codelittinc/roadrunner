# frozen_string_literal: true

require 'rails_helper'
require 'external_api_helper'

RSpec.describe Clients::Github::Release, type: :service do
  describe '#list' do
    it 'returns a list of releases' do
      VCR.use_cassette('github#release#list') do
        repository = FactoryBot.create(:repository, owner: 'codelittinc', name: 'codelitt-v2')
        commits = described_class.new.list(repository)
        expect(commits.size).to eql(100)
      end
    end
  end

  describe '#create' do
    it 'creates a release' do
      VCR.use_cassette('github#release#create') do
        repository = FactoryBot.create(:repository, owner: 'codelittinc', name: 'gh-hooks-repo-test')
        tag_name = 'rc.3.v0.0.29'
        body = "this \n is \n nice"
        described_class.new.create(repository, tag_name, 'master', body, true)

        release = described_class.new.list(repository).first

        expect(release).to be_a(Clients::Github::Parsers::ReleaseParser)
      end
    end
  end

  describe '#delete' do
    it 'deletes a release' do
      VCR.use_cassette('github#release#delete') do
        repository = FactoryBot.create(:repository, owner: 'codelittinc', name: 'gh-hooks-repo-test')
        release_to_delete = described_class.new.list(repository).first
        described_class.new.delete(release_to_delete.url)
        release_to_check = described_class.new.list(repository).first

        expect(release_to_delete.tag_name).not_to eql(release_to_check.tag_name)
      end
    end
  end
end
