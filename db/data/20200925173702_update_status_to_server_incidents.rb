# frozen_string_literal: true

class UpdateStatusToServerIncidents < ActiveRecord::Migration[6.0]
  def up
    ServerIncident.find_each do |s|
      s.update(status: 'completed')
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
