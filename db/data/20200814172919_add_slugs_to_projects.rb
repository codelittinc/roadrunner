class AddSlugsToProjects < ActiveRecord::Migration[6.0]
  def up
    Project.find_each(&:save)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
