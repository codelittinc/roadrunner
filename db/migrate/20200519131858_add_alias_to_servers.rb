class AddAliasToServers < ActiveRecord::Migration[6.0]
  def change
    add_column :servers, :alias, :string
  end
end
