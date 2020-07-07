require 'rails_helper'

RSpec.describe Clients::LegacyRoadrunner::PullRequest, type: :service do
  describe '#by_github_id_and_repository' do
    it 'returns a valid legacy pull request' do
      legacy_pull_request = described_class.by_github_id_and_repository(1050, 'codelitt-v2')
      expect(legacy_pull_request["ghId"]).to eql(1050)
    end
  end
end
