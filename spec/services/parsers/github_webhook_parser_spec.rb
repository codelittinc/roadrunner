require 'rails_helper'

RSpec.describe Parsers::GithubWebhookParser, type: :service do
  let(:pull_request) do
    JSON.parse(File.read(File.join('spec', 'fixtures', 'services', 'flows', 'github_new_pull_request.json'))).with_indifferent_access
  end

  let(:review_json) do
    JSON.parse(File.read(File.join('spec', 'fixtures', 'services', 'flows', 'new_review_submission_request.json'))).with_indifferent_access
  end
  describe 'returns true when' do
    it 'read the pull request' do
      flow = described_class.new(pull_request)

      expect(flow.can_parse?).to be_truthy
    end

    it 'read the review' do
      flow = described_class.new(review_json)
      flow.parse!

      expect(flow.review).to be_truthy
    end

    it 'read review_state' do
      flow = described_class.new(review_json)
      flow.parse!

      expect(flow.review_state).to be_truthy
    end

    it 'read review_username' do
      flow = described_class.new(review_json)
      flow.parse!

      expect(flow.review_username).to be_truthy
    end

    it 'the review_username equals from the json' do
      flow = described_class.new(review_json)
      flow.parse!

      expect(flow.review_username).to eql('kaiomagalhaes')
    end

    it 'the review_body equals from the json' do
      flow = described_class.new(review_json)
      flow.parse!

      expect(flow.review_body).to eql('dasdasdsa')
    end

    it 'the review_state equals from the json' do
      flow = described_class.new(review_json)
      flow.parse!

      expect(flow.review_state).to eql('commented')
    end
  end
end
