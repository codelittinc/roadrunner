# frozen_string_literal: true

class CreateCommitReleases < ActiveRecord::Migration[6.1]
  def change
    create_table :commit_releases do |t|
      t.belongs_to :commit
      t.belongs_to :release
      t.timestamps
    end
  end
end
