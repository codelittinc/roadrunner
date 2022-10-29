class AddActiveToRepository < ActiveRecord::Migration[7.0]
  def change
    add_column :repositories, :active, :boolean
  end
end
