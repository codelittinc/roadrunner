require 'rails_helper'
# require 'external_api_helper'

RSpec.describe Flows::ClosePullRequestFlow, type: :service do
  let(:valid_json) do
    JSON.parse(File.read(File.join('spec', 'fixtures', 'services', 'flows', 'github_close_pull_request.json'))).with_indifferent_access
  end

  describe '#flow?' do
    context 'returns true when' do
      it 'a pull request exists and it is open' do
        FactoryBot.create(:pull_request, github_id: 13)

        flow = described_class.new(valid_json)
        expect(flow.flow?).to be_truthy
      end
    end

    context 'returns false when' do
      it 'a pull request exists but it is closed' do
        pr = FactoryBot.create(:pull_request, github_id: 13)
        pr.merge!

        flow = described_class.new(valid_json)
        expect(flow.flow?).to be_falsey
      end

      it 'a pull request exists but it is cancelled' do
        pr = FactoryBot.create(:pull_request, github_id: 13)
        pr.cancel!

        flow = described_class.new(valid_json)
        expect(flow.flow?).to be_falsey
      end

      it 'a pull request does not exist' do
        flow = described_class.new(valid_json)
        expect(flow.flow?).to be_falsey
      end
    end
  end

  xdescribe '#execute' do
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
