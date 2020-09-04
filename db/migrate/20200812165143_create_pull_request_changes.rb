# frozen_string_literal: true

class CreatePullRequestChanges < ActiveRecord::Migration[6.0]
  def change
    create_table :pull_request_changes do |t|
      t.belongs_to :pull_request, null: false, foreign_key: true

      t.timestamps
    end
  end
end
