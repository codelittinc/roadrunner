# frozen_string_literal: true

class RemoveExternalIdentifierFromApplication < ActiveRecord::Migration[6.1]
  def change
    remove_column :applications, :external_identifier, :string
  end
end
