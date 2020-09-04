# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :github
      t.string :jira
      t.string :slack

      t.timestamps
    end
  end
end
