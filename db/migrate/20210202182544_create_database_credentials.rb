# frozen_string_literal: true

class CreateDatabaseCredentials < ActiveRecord::Migration[6.1]
  def change
    create_table :database_credentials do |t|
      t.string :env
      t.string :type
      t.string :name
      t.string :db_host
      t.string :db_user
      t.string :db_name
      t.string :db_password

      t.timestamps
    end
  end
end
