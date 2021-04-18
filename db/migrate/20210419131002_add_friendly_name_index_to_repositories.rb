# frozen_string_literal: true

class AddFriendlyNameIndexToRepositories < ActiveRecord::Migration[6.1]
  def change
    add_index :repositories, :friendly_name, unique: true
  end
end
