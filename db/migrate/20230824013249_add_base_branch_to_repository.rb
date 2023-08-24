class AddBaseBranchToRepository < ActiveRecord::Migration[7.0]
  def change
    add_column :repositories, :base_branch, :string
  end
end
