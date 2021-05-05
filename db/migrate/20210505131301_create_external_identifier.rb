# frozen_string_literal: true

class CreateExternalIdentifier < ActiveRecord::Migration[6.1]
  def change
    create_table :external_identifiers do |t|
      t.string :text
      t.belongs_to :application

      t.timestamps
    end
  end
end
