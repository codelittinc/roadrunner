# frozen_string_literal: true

class AddCiStateToPullRequest < ActiveRecord::Migration[6.0]
  def change
    add_column :pull_requests, :ci_state, :string
  end
end
