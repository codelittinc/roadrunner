# frozen_string_literal: true

class CreateAzurePullRequests < ActiveRecord::Migration[6.1]
  def change
    create_table :azure_pull_requests do |t|
      t.string :azure_id
      t.belongs_to :pull_request

      t.timestamps
    end
  end
end
