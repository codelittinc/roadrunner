# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommitsMatcher, type: :service do
  let(:repository) do
    FactoryBot.create(:repository, owner: 'codelittinc', name: 'roadrunner')
  end

  let(:pull_request) do
    FactoryBot.create(:pull_request, repository:)
  end

  it 'returns a list of commits' do
    VCR.use_cassette('services#commits-matcher#list-commits') do
      github_commits = Clients::Github::Branch.new.commits(repository, 'master').reverse
      commits = [
        FactoryBot.create(:commit, pull_request:,
                                   message: 'update rails admin to use master while they release a version compatible with ruby 3'),
        FactoryBot.create(:commit, pull_request:, message: 'add rails admin dependencies'),
        FactoryBot.create(:commit, pull_request:, message: 'fix rubocop issues after rubocop update')
      ]

      matched_commits = CommitsMatcher.new(github_commits, repository).commits

      expect(matched_commits).to eql(commits)
    end
  end

  it 'when there are two commits with the same message it returns the latest one' do
    VCR.use_cassette('services#commits-matcher#list-commits') do
      github_commits = Clients::Github::Branch.new.commits(repository, 'master').reverse
      message = 'update rails admin to use master while they release a version compatible with ruby 3'
      FactoryBot.create(:commit, pull_request:, message:, created_at: 5.days.ago, author_name: 'robin')
      FactoryBot.create(:commit, pull_request:, message:, created_at: 2.days.ago, author_name: 'batman')

      matched_commits = CommitsMatcher.new(github_commits, repository).commits

      expect(matched_commits.first.author_name).to eql('batman')
    end
  end
end
