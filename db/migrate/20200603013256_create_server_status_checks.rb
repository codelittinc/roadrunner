# frozen_string_literal: true

class CreateServerStatusChecks < ActiveRecord::Migration[6.0]
  def change
    create_table :server_status_checks do |t|
      t.integer :code
      t.belongs_to :server

      t.timestamps
    end
  end
end
