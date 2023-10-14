# frozen_string_literal: true

class AddBackstageIdToPullRequests < ActiveRecord::Migration[7.0]
  def change
    add_column :pull_requests, :backstage_user_id, :integer
  end
end
