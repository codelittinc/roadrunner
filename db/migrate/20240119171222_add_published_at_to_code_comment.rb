# frozen_string_literal: true

class AddPublishedAtToCodeComment < ActiveRecord::Migration[7.0]
  def change
    add_column :code_comments, :published_at, :date
  end
end
