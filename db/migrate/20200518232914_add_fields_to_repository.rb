# frozen_string_literal: true

class AddFieldsToRepository < ActiveRecord::Migration[6.0]
  def change
    add_column :repositories, :deploy_type, :string
    add_column :repositories, :supports_deploy, :boolean
  end
end
