# frozen_string_literal: true

class RemoveTypeFromServerIncident < ActiveRecord::Migration[6.0]
  def change
    remove_column :server_incidents, :type, :string
  end
end
