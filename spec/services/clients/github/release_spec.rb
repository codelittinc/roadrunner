require 'rails_helper'
require 'external_api_helper'

RSpec.describe Clients::Github::Release, type: :service do
  describe '#list' do
    it 'returns a list of releases' do
      VCR.use_cassette('github#release#list') do
        commits = described_class.new.list('codelittinc/codelitt-v2')
        expect(commits.size).to eql(30)
      end
    end
  end
end
