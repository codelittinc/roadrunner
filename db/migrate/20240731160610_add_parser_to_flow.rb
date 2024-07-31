# frozen_string_literal: true

class AddParserToFlow < ActiveRecord::Migration[7.0]
  def change
    add_column :flow_requests, :parser_name, :string
  end
end
