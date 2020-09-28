# frozen_string_literal: true

class CreateServerIncidentInstances < ActiveRecord::Migration[6.0]
  def change
    create_table :server_incident_instances do |t|
      t.references :server_incident, null: false, foreign_key: true

      t.timestamps
    end
  end
end
