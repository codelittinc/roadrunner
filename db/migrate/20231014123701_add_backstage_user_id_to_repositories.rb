# frozen_string_literal: true

class AddBackstageUserIdToRepositories < ActiveRecord::Migration[7.0]
  def change
    add_column :repositories, :backstage_user_id, :integer
  end
end
