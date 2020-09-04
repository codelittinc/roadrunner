# frozen_string_literal: true

class CreatePullRequestReviews < ActiveRecord::Migration[6.0]
  def change
    create_table :pull_request_reviews do |t|
      t.string :state
      t.string :username
      t.belongs_to :pull_request, null: false, foreign_key: true

      t.timestamps
    end
  end
end
