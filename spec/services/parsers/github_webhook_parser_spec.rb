# frozen_string_literal: true

require 'rails_helper'
require 'flows_helper'

RSpec.describe Parsers::GithubWebhookParser, type: :service do
  let(:pull_request) { load_flow_fixture('github_new_pull_request.json') }

  describe 'returns true when' do
    it 'read the pull request' do
      parser = described_class.new(pull_request)

      expect(parser.can_parse?).to be_truthy
    end
  end
end
