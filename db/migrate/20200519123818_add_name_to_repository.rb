class AddNameToRepository < ActiveRecord::Migration[6.0]
  def change
    add_column :repositories, :name, :string
  end
end
