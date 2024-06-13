# frozen_string_literal: true

class AddPullRequestPathFilterToRepository < ActiveRecord::Migration[7.0]
  def change
    add_column :repositories, :pull_request_path_filter, :string
  end
end
