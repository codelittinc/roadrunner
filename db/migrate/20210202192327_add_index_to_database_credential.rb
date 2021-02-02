# frozen_string_literal: true

class AddIndexToDatabaseCredential < ActiveRecord::Migration[6.1]
  def change
    add_index :database_credentials, :db_host, unique: true
    add_index :database_credentials, :name, unique: true
  end
end
