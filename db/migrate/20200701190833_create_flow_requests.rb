# frozen_string_literal: true

class CreateFlowRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :flow_requests do |t|
      t.string :json
      t.string :flow_name
      t.boolean :executed

      t.timestamps
    end
  end
end
