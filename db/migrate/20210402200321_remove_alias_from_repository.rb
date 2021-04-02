# frozen_string_literal: true

class RemoveAliasFromRepository < ActiveRecord::Migration[6.1]
  def change
    remove_column :repositories, :alias, :string
  end
end
