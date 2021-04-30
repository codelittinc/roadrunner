# frozen_string_literal: true

class RemovePullRequestIdFromAzurePullRequest < ActiveRecord::Migration[6.1]
  def change
    remove_column :azure_pull_requests, :pull_request_id, :bigint
  end
end
