# frozen_string_literal: true

class AddProjectReferenceToRepository < ActiveRecord::Migration[6.0]
  def change
    add_reference :repositories, :project, index: true
  end
end
