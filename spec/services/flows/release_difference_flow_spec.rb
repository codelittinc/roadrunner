# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Flows::ReleaseDifferenceFlow, type: :service do
  let(:repository) { FactoryBot.create(:repository) }
  let(:application) { FactoryBot.create(:application, repository:) }
  let(:base_release) { FactoryBot.create(:release, application:) }
  let(:head_release) { FactoryBot.create(:release, application:) }

  let(:commits) do
    FactoryBot.create(:commit, :with_pull_request,
                      message: 'commit on Base Release', release_ids: [base_release.id])
    FactoryBot.create(:commit, :with_pull_request, message: 'commit on both releases',
                                                   release_ids: [base_release.id, head_release.id])
    FactoryBot.create(:commit, :with_pull_request, message: 'first commit on Head Release',
                                                   release_ids: [head_release.id])
    FactoryBot.create(:commit, :with_pull_request, message: 'second commit on Head Release',
                                                   release_ids: [head_release.id])
  end

  describe '#can_execute?' do
    context 'returns true' do
      it 'with a valid json' do
        flow = described_class.new({
                                     text: "release diff #{repository.name} #{base_release.version} #{head_release.version}",
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

      it 'an release does not exists' do
        flow = described_class.new({
                                     text: "env diff #{repository.name} #{base_release.version} fake_release_version",
                                     channel_name: 'cool-channel'
                                   })
        expect(flow.can_execute?).to be_falsey
      end

      it 'a repository does not exists' do
        flow = described_class.new({
                                     text: "env diff fake_repository #{base_release} #{head_release}",
                                     channel_name: 'cool-channel'
                                   })
        expect(flow.can_execute?).to be_falsey
      end

      it 'there are missing parameters' do
        flow = described_class.new({
                                     text: "env diff #{repository.name}",
                                     channel_name: 'cool-channel'
                                   })
        expect(flow.can_execute?).to be_falsey
      end
    end
  end

  describe '#execute' do
    context 'with a valid json' do
      it 'returns the commit list' do
        commits

        flow = described_class.new({
                                     text: "release diff #{repository.name} #{base_release.version} #{head_release.version}",
                                     channel_name: 'cool-channel',
                                     user_name: 'sattler'
                                   })

        expect_any_instance_of(Clients::Notifications::Direct).to receive(:send).with(
          "The differente between #{base_release.version} and #{head_release.version} is:\n - first commit on Head Release\n - second commit on Head Release", 'sattler'
        )

        flow.execute
      end
    end
  end
end
