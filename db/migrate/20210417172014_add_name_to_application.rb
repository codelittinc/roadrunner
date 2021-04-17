# frozen_string_literal: true

class AddNameToApplication < ActiveRecord::Migration[6.1]
  def change
    add_column :applications, :name, :string
  end
end
