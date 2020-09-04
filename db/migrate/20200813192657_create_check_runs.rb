# frozen_string_literal: true

class CreateCheckRuns < ActiveRecord::Migration[6.0]
  def change
    create_table :check_runs do |t|
      t.string :state
      t.string :commit_sha

      t.timestamps
    end
  end
end
