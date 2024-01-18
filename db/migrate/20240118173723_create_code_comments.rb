# frozen_string_literal: true

class CreateCodeComments < ActiveRecord::Migration[7.0]
  def change
    create_table :code_comments do |t|
      t.integer :author_id
      t.references :pull_request, null: false, foreign_key: true
      t.string :comment

      t.timestamps
    end
  end
end
