# frozen_string_literal: true

class RenameClientToCustomer < ActiveRecord::Migration[6.1]
  def change
    rename_table :clients, :customers
  end
end
