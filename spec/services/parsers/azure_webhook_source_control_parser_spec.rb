# frozen_string_literal: true

require 'rails_helper'
require 'flows_helper'
require 'external_api_helper'

RSpec.describe Flows::Repositories::PullRequest::Create::AzureParser, type: :service do
  let(:new_pull_request) { load_flow_fixture('azure_new_pull_request.json') }
  let(:updated_pull_request) { load_flow_fixture('azure_updated_pull_request.json') }
  let(:close_pull_request) { load_flow_fixture('azure_close_pull_request.json') }
  let(:checkrun_flow) { load_flow_fixture('azure_checkrun_flow.json') }
  let(:failed_checkrun_flow) { load_flow_fixture('azure_failed_checkrun_flow.json') }

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

  xcontext '#parse!' do
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

    xit 'parses the commit sha properly' do
      VCR.use_cassette('flows#check-run#azure-create-check-run-data') do
        flow = described_class.new(checkrun_flow)
        flow.parse!

        expect(flow.commit_sha).to eql('69d850430ee11df6420ee29f654ab0bcbc99a7ee')
      end
    end

    it 'parses the branch name properly' do
      VCR.use_cassette('flows#check-run#azure-create-check-run-data') do
        flow = described_class.new(checkrun_flow)
        flow.parse!

        expect(flow.branch_name).to eql('update/new-charts-styles')
      end
    end

    it 'parses the conclusion properly when succeeded' do
      VCR.use_cassette('flows#check-run#azure-create-check-run-data') do
        flow = described_class.new(checkrun_flow)
        flow.parse!

        expect(flow.conclusion).to eql('success')
      end
    end

    it 'parses the conclusion properly when failed' do
      VCR.use_cassette('flows#check-run#azure-create-check-run-data') do
        flow = described_class.new(failed_checkrun_flow)
        flow.parse!

        expect(flow.conclusion).to eql('failure')
      end
    end
  end

  xcontext '#new_pull_request_flow?' do
    it 'returns true when the event_type is created' do
      flow = described_class.new(new_pull_request)
      flow.parse!

      expect(flow.new_pull_request_flow?).to be_truthy
    end

    it 'returns true when the event_type is updated' do
      flow = described_class.new(updated_pull_request)
      flow.parse!

      expect(flow.new_pull_request_flow?).to be_truthy
    end

    it 'returns false when the event_type is not updated or created' do
      flow = described_class.new(close_pull_request)
      flow.parse!

      expect(flow.new_pull_request_flow?).to be_falsy
    end
  end

  xcontext '#close_pull_request_flow?' do
    it 'returns true when the status is completed' do
      flow = described_class.new(close_pull_request)
      flow.parse!

      expect(flow.close_pull_request_flow?).to be_truthy
    end

    it 'returns true when the status is different from completed' do
      close_pull_request_clone = close_pull_request.deep_dup
      close_pull_request_clone[:resource][:status] = 'active'
      flow = described_class.new(close_pull_request_clone)
      flow.parse!

      expect(flow.close_pull_request_flow?).to be_falsy
    end
  end
end
