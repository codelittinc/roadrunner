# frozen_string_literal: true

class AddActiveToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :active, :bool, default: true
  end
end
