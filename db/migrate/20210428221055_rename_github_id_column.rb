# frozen_string_literal: true

class RenameGithubIdColumn < ActiveRecord::Migration[6.1]
  def change
    rename_column :pull_requests, :github_id, :source_control_id
  end
end
