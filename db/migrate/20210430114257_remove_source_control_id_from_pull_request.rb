# frozen_string_literal: true

class RemoveSourceControlIdFromPullRequest < ActiveRecord::Migration[6.1]
  def change
    remove_column :pull_requests, :source_control_id, :string
  end
end
