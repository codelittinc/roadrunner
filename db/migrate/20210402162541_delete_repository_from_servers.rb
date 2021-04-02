class DeleteRepositoryFromServers < ActiveRecord::Migration[6.1]
  def change
    remove_column :servers, :repository_id, :int
  end
end
