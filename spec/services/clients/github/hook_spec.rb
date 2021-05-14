# frozen_string_literal: true

require 'rails_helper'
require 'external_api_helper'

RSpec.describe Clients::Github::Hook, type: :service do
  let(:repository) do
    FactoryBot.create(:repository, owner: 'codelittinc', name: 'gh-hooks-repo-test')
  end

  describe '#create' do
    it 'creates a hook' do
      VCR.use_cassette('github#create_hook') do
        url = 'https://roadrunner.codelitt.dev/flows'

        described_class.new.create(repository)
        hook_found = described_class.new.list(repository).find { |hook| url.match?(hook[:config][:url]) }.present?

        expect(hook_found).to eql(true)
      end
    end

    it 'returns success when the repo already exists' do
      VCR.use_cassette('github#create_existing_hook') do
        response = described_class.new.create(repository)

        expect(response[:status]).to eql(200)
      end
    end
  end

  describe '#list' do
    it 'returns a list of hooks' do
      VCR.use_cassette('github#hooks#list') do
        hooks = described_class.new.list(repository)

        expect(hooks.size).to be > 0
      end
    end
  end
end
