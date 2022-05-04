# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Flows::EnvironmentDifferenceFlow, type: :service do
  let(:repository) { FactoryBot.create(:repository) }
  let(:qa_application) { FactoryBot.create(:application, environment: 'qa', repository: repository) }
  let(:prod_application) { FactoryBot.create(:application, environment: 'prod', repository: repository) }
  let(:qa_release) { FactoryBot.create(:release, application: qa_application) }
  let(:prod_release) { FactoryBot.create(:release, application: prod_application) }

  let(:commits) do
    FactoryBot.create(:commit, :with_pull_request,
                      message: 'commit on Prod Environment', release_ids: [prod_release.id])
    FactoryBot.create(:commit, :with_pull_request, message: 'commit on both environments',
                                                   release_ids: [prod_release.id, qa_release.id])
    FactoryBot.create(:commit, :with_pull_request, message: 'first commit on QA Environment',
                                                   release_ids: [qa_release.id])
    FactoryBot.create(:commit, :with_pull_request, message: 'second commit on QA Environment',
                                                   release_ids: [qa_release.id])
  end

  describe '#can_execute?' do
    context 'returns true' do
      it 'with a valid json' do
        flow = described_class.new({
                                     text: "env diff #{repository.name} #{prod_application.environment} #{qa_application.environment}",
                                     channel_name: 'cool-channel'
                                   })
        expect(flow.can_execute?).to be_truthy
      end
    end

    context 'returns false' do
      it 'when there is no text' do
        flow = described_class.new({
                                     channel_name: 'cool-channel'
                                   })
        expect(flow.can_execute?).to be_falsey
      end

      it 'when an environment does not exists' do
        flow = described_class.new({
                                     text: "env diff #{repository.name} #{prod_application.environment} fake_env",
                                     channel_name: 'cool-channel'
                                   })
        expect(flow.can_execute?).to be_falsey
      end

      it 'when a repository does not exists' do
        flow = described_class.new({
                                     text: "env diff fake_repository #{prod_application.environment} #{qa_application.environment}",
                                     channel_name: 'cool-channel'
                                   })
        expect(flow.can_execute?).to be_falsey
      end

      it 'when there are missing parameters' do
        flow = described_class.new({
                                     text: "env diff #{repository.name}",
                                     channel_name: 'cool-channel'
                                   })
        expect(flow.can_execute?).to be_falsey
      end
    end

    describe '#execute' do
      context 'with a valid json' do
        it 'sends a direct message to the requester with the list of differences' do
          prod_release
          qa_release
          commits

          flow = described_class.new({
                                       text: "release diff #{repository.name} #{prod_application.environment} #{qa_application.environment}",
                                       channel_name: 'cool-channel',
                                       user_name: 'sattler'
                                     })

          expect_any_instance_of(Clients::Slack::DirectMessage).to receive(:send).with(
            "The differente between #{prod_application.environment} and #{qa_application.environment} is:\n - first commit on QA Environment\n - second commit on QA Environment", 'sattler'
          )

          flow.execute
        end
      end
    end
  end
end
