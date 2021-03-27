# frozen_string_literal: true

require "rails_helper"

RSpec.describe FetchServerCommits, type: :service do
  it "should return all server commits" do
    repository = FactoryBot.create(:repository)
    server = FactoryBot.create(:server, repository_id: repository.id)
    pull_request = FactoryBot.create(:pull_request, repository_id: repository.id)
    commit = FactoryBot.create(:commit, pull_request_id: pull_request.id)
    second_pull_request = FactoryBot.create(:pull_request, repository_id: repository.id, github_id: 2)
    second_commit = FactoryBot.create(:commit, pull_request_id: second_pull_request.id)

    commits_list = FetchServerCommits.server_commits(server.id)
    expect(commits_list).to eq([second_commit, commit])
  end
end
