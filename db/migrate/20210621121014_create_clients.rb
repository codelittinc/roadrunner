# frozen_string_literal: true

class CreateClients < ActiveRecord::Migration[6.1]
  def change
    create_table :clients do |t|
      t.string :name
      t.string :slack_api_key
      t.string :github_api_key

      t.timestamps
    end
  end
end
