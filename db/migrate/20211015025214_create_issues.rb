# frozen_string_literal: true

class CreateIssues < ActiveRecord::Migration[6.1]
  def change
    create_table :issues do |t|
      t.string :story_type
      t.string :state
      t.string :title
      t.numeric :story_points

      t.timestamps
    end
  end
end
