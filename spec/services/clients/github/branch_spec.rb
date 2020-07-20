require 'rails_helper'
require 'external_api_helper'

RSpec.describe Clients::Github::Branch, type: :service do
  describe '#commits' do
    it 'returns a list of commits' do
      VCR.use_cassette('github#branch#commits') do
        commits = described_class.new.commits('codelittinc/test-gh-notifications', 'master')
        expect(commits.size).to eql(30)
      end
    end
  end
end
