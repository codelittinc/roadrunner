# frozen_string_literal: true

class FixTypeToDatabaseCredentials < ActiveRecord::Migration[6.1]
  def up
    rename_column :database_credentials, :type, :database_type
  end
end
