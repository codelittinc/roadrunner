# frozen_string_literal: true

require 'rails_helper'
require 'external_api_helper'
require 'flows_helper'

RSpec.describe Clients::Github::Parsers::PullRequestParser, type: :service do
  context 'Github pull request JSON' do
    let(:valid_json) { load_fixture('github_pull_request.json') }
    let(:pull_request) { described_class.new(valid_json) }

    describe '#parser' do
      it 'returns a pull request object' do
        expect(pull_request).not_to be_nil
      end

      it 'returns the mergeable state' do
        expect(pull_request.mergeable_state).to eql('dirty')
      end

      it 'returns mergeable' do
        expect(pull_request.mergeable).to eql(false)
      end
    end
  end
end
