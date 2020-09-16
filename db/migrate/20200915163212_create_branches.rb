# frozen_string_literal: true

class CreateBranches < ActiveRecord::Migration[6.1]
  def change
    create_table :branches do |t|
      t.string :name
      t.references :repository, null: false, foreign_key: true
      t.references :pull_request, null: true, foreign_key: true

      t.timestamps
    end
  end
end
