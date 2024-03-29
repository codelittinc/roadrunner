# frozen_string_literal: true

require 'rails_helper'
require 'external_api_helper'
require 'json'

RSpec.describe Flows::Releases::Repositories::Update::Flow, type: :service do
  around do |example|
    ClimateControl.modify NOTIFICATIONS_API_URL: 'https://api.notifications.codelitt.dev' do
      example.run
    end
  end

  let(:valid_json) do
    JSON.parse(File.read(File.join('spec', 'fixtures', 'services', 'flows',
                                   'release_by_repository_tag.json'))).with_indifferent_access
  end

  let(:repository_with_applications) do
    repository = FactoryBot.create(:repository, owner: 'codelittinc', name: 'roadrunner-repository-test')
    repository.applications << FactoryBot.create(:application, repository:, environment: 'prod')
    repository.applications << FactoryBot.create(:application, repository:, environment: 'qa')
    repository.applications << FactoryBot.create(:application, repository:, environment: 'uat')
    repository
  end

  describe '#can_execute?' do
    context 'returns true' do
      it 'when the json is valid and there are multiple repositories tied to the slack channel' do
        repository_with_applications
        FactoryBot.create(:repository)

        flow = described_class.new(valid_json)
        expect(flow.can_execute?).to be_truthy
      end

      it 'when the environment is qa, uat or prod' do
        repository_with_applications
        FactoryBot.create(:repository)

        %w[qa uat prod].each do |env|
          flow = described_class.new({
                                       text: "update roadrunner-repository-test #{env}",
                                       channel_name: 'feed-test-automations'
                                     })

          expect(flow.can_execute?).to be_truthy
        end
      end
    end

    context 'returns false' do
      it 'when the environment is different from qa, uat or prod' do
        repository_with_applications

        flow = described_class.new({
                                     text: 'update roadrunner-repository-test prodd',
                                     channel_name: 'feed-test-automations'
                                   })

        expect(flow.can_execute?).to be_falsey
      end

      it 'when the json is valid, but repository does not exist' do
        flow = described_class.new(valid_json)
        expect(flow.can_execute?).to be_falsey
      end

      it 'when the text words number is different from three' do
        repository_with_applications
        flow = described_class.new({
                                     text: 'update prod',
                                     channel_name: 'feed-test-automations'
                                   })
        expect(flow.can_execute?).to be_falsey
      end
    end
  end

  describe '#run' do
    context 'with the qa environment' do
      it 'sends a start release notification to the channel' do
        repository_with_applications
        FactoryBot.create(:repository)

        flow = described_class.new({
                                     text: 'update roadrunner-repository-test qa',
                                     channel_name: 'feed-test-automations'
                                   })

        expect_any_instance_of(Clients::Notifications::Channel).to receive(:send).with(
          'Update release to *roadrunner-repository-test* *QA* triggered by @', 'feed-test-automations'
        )
        expect_any_instance_of(Clients::Github::Release).to receive(:list)
        expect_any_instance_of(Flows::SubFlows::ReleaseCandidateFlow).to receive(:execute)

        flow.run
      end

      it 'calls the release candidate subflow' do
        repository_with_applications
        FactoryBot.create(:repository)

        flow = described_class.new({
                                     text: 'update roadrunner-repository-test qa',
                                     channel_name: 'feed-test-automations'
                                   })

        expect_any_instance_of(Clients::Notifications::Channel).to receive(:send)
        expect_any_instance_of(Clients::Github::Release).to receive(:list)
        expect_any_instance_of(Flows::SubFlows::ReleaseCandidateFlow).to receive(:execute)

        flow.run
      end
    end

    context 'with the prod environment' do
      it 'calls the release candidate subflow' do
        repository_with_applications
        FactoryBot.create(:repository)

        flow = described_class.new({
                                     text: 'update roadrunner-repository-test prod',
                                     channel_name: 'feed-test-automations'
                                   })

        expect_any_instance_of(Clients::Notifications::Channel).to receive(:send)
        expect_any_instance_of(Clients::Github::Release).to receive(:list)
        expect_any_instance_of(Flows::SubFlows::ReleaseStableFlow).to receive(:execute)

        flow.run
      end
    end
  end
end
