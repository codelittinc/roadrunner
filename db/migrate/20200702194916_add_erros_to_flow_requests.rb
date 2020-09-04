# frozen_string_literal: true

class AddErrosToFlowRequests < ActiveRecord::Migration[6.0]
  def change
    add_column :flow_requests, :error_message, :string
  end
end
