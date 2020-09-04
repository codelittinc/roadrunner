# frozen_string_literal: true

class AddIndexToPullRequest < ActiveRecord::Migration[6.0]
  def change
    add_index :pull_requests, %i[github_id repository_id], unique: true
  end
end
