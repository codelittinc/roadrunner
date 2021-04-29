# frozen_string_literal: true

class ChangeGithubId < ActiveRecord::Migration[6.1]
  def change
    rename_column :github_pull_requests, :github_id, :source_control_id
  end
end
