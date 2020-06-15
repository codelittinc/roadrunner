class AddAliasToRepositories < ActiveRecord::Migration[6.0]
  def change
    add_column :repositories, :alias, :string
  end
end
