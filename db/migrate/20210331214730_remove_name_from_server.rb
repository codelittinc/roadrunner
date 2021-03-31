# frozen_string_literal: true

class RemoveNameFromServer < ActiveRecord::Migration[6.1]
  def change
    remove_column :servers, :name, :string
  end
end
