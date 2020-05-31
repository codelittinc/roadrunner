class AddEnvironmentToServers < ActiveRecord::Migration[6.0]
  def change
    add_column :servers, :environment, :string
  end
end
