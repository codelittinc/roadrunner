# frozen_string_literal: true

class AddServerIncidentServiceToApplication < ActiveRecord::Migration[6.1]
  def change
    # rubocop:disable Rails/BulkChangeTable
    remove_column :server_incidents, :server_id, :int
    add_column :server_incidents, :application_id, :int
    # rubocop:enable Rails/BulkChangeTable
  end
end
