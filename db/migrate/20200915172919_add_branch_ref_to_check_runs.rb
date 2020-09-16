# frozen_string_literal: true

class AddBranchRefToCheckRuns < ActiveRecord::Migration[6.1]
  def change
    add_reference :check_runs, :branch, null: true
  end
end
