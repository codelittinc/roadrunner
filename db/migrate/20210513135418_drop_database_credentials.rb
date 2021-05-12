# frozen_string_literal: true

class DropDatabaseCredentials < ActiveRecord::Migration[6.1]
  def change
    drop_table :database_credentials do |t|
      t.string :name
    end
  end
end
