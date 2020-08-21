class AddNameToServers < ActiveRecord::Migration[6.0]
  def change
    add_column :servers, :name, :string
  end
end
