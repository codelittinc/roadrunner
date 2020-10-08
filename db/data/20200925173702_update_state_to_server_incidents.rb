# frozen_string_literal: true

class UpdateStateToServerIncidents < ActiveRecord::Migration[6.0]
  def up
    ServerIncident.find_each do |s|
      s.update(state: 'completed')
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
