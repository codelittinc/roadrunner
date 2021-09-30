# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Flows::ReleaseDifferenceFlow, type: :service do
  let(:repository) { FactoryBot.create(:repository) }
  let(:application) { FactoryBot.create(:application, repository: repository) }

  describe '#can_execute?' do
    context 'with a valid json' do
      it 'returns true' do
        flow = described_class.new({
                                     text: 'release diff RepositoryName BaseRelease HeadRelease',
                                     channel_name: 'cool-channel'
                                   })
        expect(flow.can_execute?).to be_truthy
      end
    end

    context 'returns false when' do
      it 'there is no text' do
        flow = described_class.new({
                                     channel_name: 'cool-channel'
                                   })
        expect(flow.can_execute?).to be_falsey
      end

      it 'text is incorrect' do
        flow = described_class.new({
                                     text: 'not release diff',
                                     channel_name: 'cool-channel'
                                   })
        expect(flow.can_execute?).to be_falsey
      end
    end
  end

  describe '#execute' do
    context 'with a valid json' do
      it 'returns the commit list' do
        base_release = FactoryBot.create(:release, application: application)
        head_release = FactoryBot.create(:release, application: application)

        FactoryBot.create(:commit, :with_pull_request,
                          message: 'commit on Base Release', release_ids: [base_release.id])
        FactoryBot.create(:commit, :with_pull_request, message: 'commit on both releases', release_ids: [base_release.id, head_release.id])
        FactoryBot.create(:commit, :with_pull_request, message: 'first commit on Head Release', release_ids: [head_release.id])
        FactoryBot.create(:commit, :with_pull_request, message: 'second commit on Head Release', release_ids: [head_release.id])

        flow = described_class.new({
                                     text: "release diff #{application.repository.name} #{base_release.version} #{head_release.version}",
                                     channel_name: 'cool-channel',
                                     user_name: 'sattler'
                                   })

        expect_any_instance_of(Clients::Slack::DirectMessage).to receive(:send).with(
          "The differente between #{base_release.version} and #{head_release.version} is:\n - first commit on Head Release\n - second commit on Head Release", 'sattler'
        )

        flow.execute
      end
    end

    context 'with a nonexistent release version' do
      it 'returns a error message' do
        flow = described_class.new({
                                     text: "release diff #{application.repository.name} NonexistentBaseReleaseVersion NonexistentHeadReleaseVersion",
                                     channel_name: 'cool-channel',
                                     user_name: 'sattler'
                                   })

        expect_any_instance_of(Clients::Slack::DirectMessage).to receive(:send).with(
          "I couldn't compare your releases. There is possibly a typo in their names or they are missing.", 'sattler'
        )

        flow.execute
      end
    end
  end
end
