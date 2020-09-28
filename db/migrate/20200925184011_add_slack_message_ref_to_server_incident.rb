# frozen_string_literal: true

class AddSlackMessageRefToServerIncident < ActiveRecord::Migration[6.0]
  def change
    add_reference :server_incidents, :slack_message, null: true
  end
end
