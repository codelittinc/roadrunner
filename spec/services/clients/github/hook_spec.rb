# frozen_string_literal: true

require 'rails_helper'
require 'external_api_helper'

RSpec.describe Clients::Github::Hook, type: :service do
  describe '#create' do
    it 'creates a hook' do
      VCR.use_cassette('github#create_hook') do
        repo = 'codelittinc/gh-hooks-repo-test'
        url = 'https://roadrunner.codelitt.dev/flows'

        described_class.new.create(repo)
        hook_found = described_class.new.list(repo).find { |hook| url.match?(hook[:config][:url]) }.present?

        expect(hook_found).to eql(true)
      end
    end
  end

  describe '#list' do
    it 'returns a list of hooks' do
      VCR.use_cassette('github#hooks#list') do
        repo = 'codelittinc/gh-hooks-repo-test'

        hooks = described_class.new.list(repo)

        expect(hooks.size).to be > 0
      end
    end
  end
end
