# frozen_string_literal: true

class AddFieldsToSlackRepositoryInfo < ActiveRecord::Migration[6.0]
  def change
    add_column :slack_repository_infos, :dev_channel, :string
    add_column :slack_repository_infos, :dev_group, :string
  end
end
