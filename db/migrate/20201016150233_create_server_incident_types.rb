# frozen_string_literal: true

class CreateServerIncidentTypes < ActiveRecord::Migration[6.0]
  def change
    create_table :server_incident_types do |t|
      t.string :name
      t.string :regex_identifier

      t.timestamps
    end
  end
end
