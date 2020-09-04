# frozen_string_literal: true

class AddMessageToSlackMessages < ActiveRecord::Migration[6.0]
  def change
    add_column :slack_messages, :text, :string
  end
end
