# frozen_string_literal: true

class CreateServers < ActiveRecord::Migration[6.0]
  def change
    create_table :servers do |t|
      t.string :link
      t.boolean :supports_health_check
      t.belongs_to :repository

      t.timestamps
    end
  end
end
