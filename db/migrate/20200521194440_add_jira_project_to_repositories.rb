# frozen_string_literal: true

class AddJiraProjectToRepositories < ActiveRecord::Migration[6.0]
  def change
    add_column :repositories, :jira_project, :string
  end
end
