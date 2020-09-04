# frozen_string_literal: true

class AddPullRequestsRelationships < ActiveRecord::Migration[6.0]
  def change
    add_reference :pull_requests, :repository, foreign_key: true
    add_reference :pull_requests, :user, foreign_key: true
  end
end
