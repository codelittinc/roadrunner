# frozen_string_literal: true

class CreateSlackMessages < ActiveRecord::Migration[6.0]
  def change
    create_table :slack_messages do |t|
      t.string :ts

      t.belongs_to :pull_request

      t.timestamps
    end
  end
end
