class CreateApplications < ActiveRecord::Migration[6.1]
  def change
    create_table :applications do |t|
      t.string :environment
      t.string :version
      t.string :external_identifier
      t.belongs_to :repository, null: false, foreign_key: true
  
      t.timestamps
    end
  end
end
