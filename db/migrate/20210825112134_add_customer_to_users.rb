# frozen_string_literal: true

class AddCustomerToUsers < ActiveRecord::Migration[6.1]
  def change
    add_reference :users, :customer, null: true, foreign_key: true
  end
end
