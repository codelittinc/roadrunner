# frozen_string_literal: true

class AddApplicationToServer < ActiveRecord::Migration[6.1]
  def change
    add_reference :servers, :application, foreign_key: true
  end
end
