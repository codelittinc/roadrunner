# frozen_string_literal: true

class AddClientToProjects < ActiveRecord::Migration[6.1]
  def change
    add_reference :projects, :client, foreign_key: true
  end
end
