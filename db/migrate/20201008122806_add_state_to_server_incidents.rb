# frozen_string_literal: true

class AddStateToServerIncidents < ActiveRecord::Migration[6.0]
  def change
    add_column :server_incidents, :state, :string
  end
end
