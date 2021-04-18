# frozen_string_literal: true

class AddFriendlyNameToRepository < ActiveRecord::Migration[6.1]
  def change
    add_column :repositories, :friendly_name, :string
  end
end
