# frozen_string_literal: true

class CreateServerIncidents < ActiveRecord::Migration[6.0]
  def change
    create_table :server_incidents do |t|
      t.string :message
      t.string :type

      t.belongs_to :server
      t.belongs_to :server_status_check

      t.timestamps
    end
  end
end
