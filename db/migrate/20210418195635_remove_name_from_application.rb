# frozen_string_literal: true

class RemoveNameFromApplication < ActiveRecord::Migration[6.1]
  def change
    remove_column :applications, :name, :string
  end
end
