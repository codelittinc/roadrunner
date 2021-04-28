class CreateSourceControls < ActiveRecord::Migration[6.1]
  def change
    create_table :source_controls do |t|
      t.string :content
      t.integer :pull_request_id
      t.integer :source_id
      t.string :source_type

      t.timestamps
    end
  end
end
