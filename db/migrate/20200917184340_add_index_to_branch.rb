# frozen_string_literal: true

class AddIndexToBranch < ActiveRecord::Migration[6.0]
  def change
    remove_index :branches, :pull_request_id
    add_index :branches, :pull_request_id, unique: true
  end
end
