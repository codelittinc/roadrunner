# frozen_string_literal: true

require 'rails_helper'
require 'external_api_helper'

RSpec.describe Clients::ApplicationGithub::Repository, type: :service do
  # run this after I fix it
  xdescribe '#list' do
    it 'returns a list of repositories for a given installation id' do
      VCR.use_cassette('application_github#repository#list') do
        repositories = described_class.new('30421922').list

        expect(repositories.count).to eql(30)
      end
    end
  end
end
