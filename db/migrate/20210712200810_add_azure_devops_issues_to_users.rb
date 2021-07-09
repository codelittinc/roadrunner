# frozen_string_literal: true

class AddAzureDevopsIssuesToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :azure_devops_issues, :string
  end
end
