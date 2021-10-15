# frozen_string_literal: true

class AddReferencesToIssues < ActiveRecord::Migration[6.1]
  def change
    add_reference :issues, :sprint, null: true, foreign_key: true
    add_reference :issues, :user, null: true, foreign_key: true
  end
end
