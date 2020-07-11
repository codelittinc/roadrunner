require 'rails_helper'
# require 'external_api_helper'

RSpec.describe Flows::ClosePullRequestFlow, type: :service do
  let(:valid_json) do
    JSON.parse(File.read(File.join('spec', 'fixtures', 'services', 'flows', 'github_close_pull_request.json'))).with_indifferent_access
  end

  describe '#isFlow?' do
    context 'when an open pull request exists' do
      it 'returns true ' do
        FactoryBot.create(:pull_request, github_id: 13)

        flow = described_class.new(valid_json)
        expect(flow.isFlow?).to be_truthy
      end
    end
  end

  describe '#execute' do
    it 'creates a set of commits from the pull request in the database' do
      repository = FactoryBot.create(:repository, name: 'roadrunner-rails')
      FactoryBot.create(:pull_request, github_id: 13, repository: repository)

      flow = described_class.new(valid_json)

      expect { flow.execute }.to change { Commit.count }.by(1)
    end

    it 'creates a set of commits from the pull request in the database with the right message' do
      repository = FactoryBot.create(:repository, name: 'roadrunner-rails')
      FactoryBot.create(:pull_request, github_id: 13, repository: repository)

      flow = described_class.new(valid_json)
      flow.execute
      expect(Commit.last.message).to eql('Enable cors')
    end
  end
end
