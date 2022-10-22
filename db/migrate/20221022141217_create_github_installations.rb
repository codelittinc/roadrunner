# frozen_string_literal: true

class CreateGithubInstallations < ActiveRecord::Migration[7.0]
  def change
    create_table :github_installations do |t|
      t.string :installation_id
      t.belongs_to :organization

      t.timestamps
    end
  end
end
