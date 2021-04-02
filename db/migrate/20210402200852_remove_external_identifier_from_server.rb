# frozen_string_literal: true

class RemoveExternalIdentifierFromServer < ActiveRecord::Migration[6.1]
  def change
    remove_column :servers, :external_identifier, :string
  end
end
