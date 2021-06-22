# frozen_string_literal: true

class RenameProjectsColumn < ActiveRecord::Migration[6.1]
  def change
    rename_column :projects, :client_id, :customer_id
  end
end
