# frozen_string_literal: true

class AddActiveToServers < ActiveRecord::Migration[6.0]
  def change
    add_column :servers, :active, :boolean, default: true
  end
end
