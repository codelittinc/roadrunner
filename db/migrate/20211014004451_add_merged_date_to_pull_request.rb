# frozen_string_literal: true

class AddMergedDateToPullRequest < ActiveRecord::Migration[6.1]
  def change
    add_column :pull_requests, :merged_at, :datetime
  end
end
