class AddCustomerToSprint < ActiveRecord::Migration[6.1]
  def change
    add_reference :sprints, :customer, null: true, foreign_key: true
  end
end
