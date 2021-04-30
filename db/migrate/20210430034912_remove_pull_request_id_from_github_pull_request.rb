# frozen_string_literal: true

class RemovePullRequestIdFromGithubPullRequest < ActiveRecord::Migration[6.1]
  def change
    remove_column :github_pull_requests, :pull_request_id, :bigint
  end
end
