# frozen_string_literal: true

# == Schema Information
#
# Table name: pull_requests
#
#  id            :bigint           not null, primary key
#  head          :string
#  base          :string
#  source_control_id     :integer
#  title         :string
#  description   :string
#  state         :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  repository_id :bigint
#  user_id       :bigint
#  ci_state      :string
#
require 'rails_helper'

RSpec.describe PullRequest, type: :model do
  describe 'should validate the props' do
    it { is_expected.to validate_presence_of(:head) }
    it { is_expected.to validate_presence_of(:base) }
    it { is_expected.to validate_presence_of(:source_control_id) }
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:state) }
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:repository) }
    it { should belong_to(:source) }
    it { should have_many(:commits).dependent(:destroy) }
    it { should have_one(:slack_message).dependent(:destroy) }
    it { should have_one(:branch).dependent(:nullify) }
    it { should have_many(:pull_request_reviews).dependent(:destroy) }
    it { should have_many(:pull_request_changes).dependent(:destroy) }
    it { should have_many(:check_runs).through(:branch) }
  end

  describe 'state machine' do
    it "defaults to 'open'" do
      pr = FactoryBot.build(:pull_request)
      expect(pr.state).to eql('open')
    end

    it 'saves the default state' do
      pr = FactoryBot.create(:pull_request)
      pr.save!
      expect(PullRequest.last.id).to eql(pr.id)
      expect(PullRequest.last.state).to eql('open')
    end

    describe 'merge!' do
      it "changes the state to 'merged'" do
        pr = FactoryBot.create(:pull_request)
        pr.merge!
        pr.reload
        expect(pr.state).to eql('merged')
      end
    end

    describe 'cancel!' do
      it "changes the state to 'cancelled'" do
        pr = FactoryBot.create(:pull_request)
        pr.cancel!
        pr.reload
        expect(pr.state).to eql('cancelled')
      end
    end

    describe '#link' do
      it 'returns a valid github link' do
        repository = FactoryBot.create(:repository, owner: 'repo-owner', name: 'repo-name')
        pr = FactoryBot.create(:pull_request, repository: repository, source_control_id: 1)
        expect(pr.link).to eql('https://github.com/repo-owner/repo-name/pull/1')
      end
    end
  end
end
