# frozen_string_literal: true

class AddOwnerToRepositories < ActiveRecord::Migration[6.0]
  def change
    add_column :repositories, :owner, :string
  end
end
