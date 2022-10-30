# frozen_string_literal: true

class RemoveFriendlyNameFromRepository < ActiveRecord::Migration[7.0]
  def change
    remove_column :repositories, :friendly_name, :string
  end
end
