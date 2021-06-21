# frozen_string_literal: true

class AddSentryNameToClient < ActiveRecord::Migration[6.1]
  def change
    add_column :clients, :sentry_name, :string
  end
end
