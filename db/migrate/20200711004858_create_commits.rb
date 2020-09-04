# frozen_string_literal: true

class CreateCommits < ActiveRecord::Migration[6.0]
  def change
    create_table :commits do |t|
      t.string :sha
      t.string :message
      t.string :author_name
      t.string :author_email

      t.belongs_to :pull_request

      t.timestamps
    end
  end
end
