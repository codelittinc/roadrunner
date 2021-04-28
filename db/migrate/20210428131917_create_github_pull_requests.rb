# frozen_string_literal: true

class CreateGithubPullRequests < ActiveRecord::Migration[6.1]
  def change
    create_table :github_pull_requests do |t|
      t.string :github_id
      t.belongs_to :pull_request
      t.timestamps
    end
  end
end
