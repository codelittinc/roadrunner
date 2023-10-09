# frozen_string_literal: true

class AddExternalProjectIdToRepositories < ActiveRecord::Migration[7.0]
  def change
    add_column :repositories, :external_project_id, :integer
  end
end
