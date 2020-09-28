# frozen_string_literal: true

class AddStatusToServerIncidents < ActiveRecord::Migration[6.0]
  def change
    add_column :server_incidents, :status, :string
  end
end
