# frozen_string_literal: true

class CreateSprints < ActiveRecord::Migration[6.1]
  def change
    create_table :sprints do |t|
      t.datetime :start_date
      t.datetime :end_date
      t.string :name
      t.string :time_frame

      t.timestamps
    end
  end
end
