# frozen_string_literal: true

class AddSourceControlTypeToRepository < ActiveRecord::Migration[6.1]
  def change
    add_column :repositories, :source_control_type, :string
  end
end
