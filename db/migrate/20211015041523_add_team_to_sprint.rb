# frozen_string_literal: true

class AddTeamToSprint < ActiveRecord::Migration[6.1]
  def change
    add_column :sprints, :team, :string
  end
end
