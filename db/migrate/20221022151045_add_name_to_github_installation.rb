# frozen_string_literal: true

class AddNameToGithubInstallation < ActiveRecord::Migration[7.0]
  def change
    add_column :github_installations, :name, :string
  end
end
