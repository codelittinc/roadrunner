# frozen_string_literal: true

class RemoveOwnerFromPullRequest < ActiveRecord::Migration[6.1]
  def change
    remove_column :pull_requests, :owner, :string
  end
end
