# frozen_string_literal: true

class AddBackstageUserIdToPullRequestReview < ActiveRecord::Migration[7.0]
  def change
    add_column :pull_request_reviews, :backstage_user_id, :integer
  end
end
