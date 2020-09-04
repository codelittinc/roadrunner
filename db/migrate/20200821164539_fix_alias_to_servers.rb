# frozen_string_literal: true

class FixAliasToServers < ActiveRecord::Migration[6.0]
  def up
    rename_column :servers, :alias, :external_identifier
  end
end
