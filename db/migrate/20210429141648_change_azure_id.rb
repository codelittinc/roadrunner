# frozen_string_literal: true

class ChangeAzureId < ActiveRecord::Migration[6.1]
  def change
    rename_column :azure_pull_requests, :azure_id, :source_control_id
  end
end
