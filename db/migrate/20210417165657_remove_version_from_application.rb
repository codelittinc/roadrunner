# frozen_string_literal: true

class RemoveVersionFromApplication < ActiveRecord::Migration[6.1]
  def change
    remove_column :applications, :version, :string
  end
end
