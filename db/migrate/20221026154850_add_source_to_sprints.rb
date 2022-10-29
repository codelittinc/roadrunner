# frozen_string_literal: true

class AddSourceToSprints < ActiveRecord::Migration[7.0]
  def change
    add_column :sprints, :source, :string
  end
end
