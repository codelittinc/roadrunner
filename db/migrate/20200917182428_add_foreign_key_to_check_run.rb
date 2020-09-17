# frozen_string_literal: true

class AddForeignKeyToCheckRun < ActiveRecord::Migration[6.0]
  def up
    add_foreign_key :check_runs, :branches
  end

  def down
    remove_foreign_key_if_exists :check_runs, column: :branch_id
  end
end
