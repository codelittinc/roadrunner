# frozen_string_literal: true

class CreateReleases < ActiveRecord::Migration[6.1]
  def change
    create_table :releases do |t|
      t.string :version
      t.references :application, foreign_key: true

      t.timestamps
    end
  end
end
