# frozen_string_literal: true

class AddDeployStatusToRelease < ActiveRecord::Migration[6.1]
  def change
    add_column :releases, :deploy_status, :string
  end
end
