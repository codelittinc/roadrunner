class AddApplicationToServer < ActiveRecord::Migration[6.1]
  def change
    add_reference :servers, :application, null: false, foreign_key: true
  end
end
