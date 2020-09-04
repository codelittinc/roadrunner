# frozen_string_literal: true

class CreatePullRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :pull_requests do |t|
      t.string :head
      t.string :base
      t.integer :github_id
      t.string :title
      t.string :description
      t.string :state
      t.string :owner

      t.timestamps
    end
  end
end
