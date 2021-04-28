# frozen_string_literal: true

class AddAzureToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :azure, :string
  end
end
