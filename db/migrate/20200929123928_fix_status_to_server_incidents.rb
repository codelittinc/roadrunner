# frozen_string_literal: true

class FixStatusToServerIncidents < ActiveRecord::Migration[6.0]
  def up
    rename_column :server_incidents, :status, :state
  end
end
