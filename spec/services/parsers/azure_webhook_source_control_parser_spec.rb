# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Parsers::AzureWebhookSourceControlParser, type: :service do
  let(:new_pull_request) do
    JSON.parse(File.read(File.join('spec', 'fixtures', 'services', 'flows', 'azure_new_pull_request.json'))).with_indifferent_access
  end

  context 'can_parse?' do
    describe 'returns true when' do
      it 'has a publisherId equal tfs' do
        flow = described_class.new(new_pull_request)

        expect(flow.can_parse?).to be_truthy
      end
    end

    describe 'returns false when' do
      it 'does not have a publisherId' do
        invalid_pull_request = {}

        flow = described_class.new(invalid_pull_request)

        expect(flow.can_parse?).to be_falsy
      end

      it 'has a publisherId different from tfs' do
        invalid_pull_request = new_pull_request.merge({
                                                        publisherId: 'this value'
                                                      })
        flow = described_class.new(invalid_pull_request)

        expect(flow.can_parse?).to be_falsy
      end
    end
  end

  context '#parse!' do
    it 'parses the base properly' do
      flow = described_class.new(new_pull_request)
      flow.parse!

      expect(flow.base).to eql('main')
    end

    it 'parses the description properly' do
      flow = described_class.new(new_pull_request)
      flow.parse!

      expect(flow.description).to eql('Added test')
    end

    it 'parses the draft properly' do
      flow = described_class.new(new_pull_request)
      flow.parse!

      expect(flow.draft).to eql(false)
    end

    it 'parses the source_control_id properly' do
      flow = described_class.new(new_pull_request)
      flow.parse!

      expect(flow.source_control_id).to eql(35)
    end

    it 'parses the owner properly' do
      flow = described_class.new(new_pull_request)
      flow.parse!

      expect(flow.owner).to eql('Avant')
    end

    it 'parses the username properly' do
      flow = described_class.new(new_pull_request)
      flow.parse!

      expect(flow.username).to eql('kaio.magalhaes@avisonyoung.onmicrosoft.com')
    end

    it 'parses the repository_name properly' do
      flow = described_class.new(new_pull_request)
      flow.parse!

      expect(flow.repository_name).to eql('ay-users-api-test')
    end

    it 'parses the title properly' do
      flow = described_class.new(new_pull_request)
      flow.parse!

      expect(flow.title).to eql('Added test')
    end
  end
end
