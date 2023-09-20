# frozen_string_literal: true

class AddFilterConfigurationToRepository < ActiveRecord::Migration[7.0]
  def change
    add_column :repositories, :filter_pull_requests_by_base_branch, :boolean
  end
end
