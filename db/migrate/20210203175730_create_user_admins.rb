# frozen_string_literal: true

class CreateUserAdmins < ActiveRecord::Migration[6.1]
  def change
    create_table :user_admins do |t|
      t.string :username
      t.string :email
      t.string :password_digest

      t.timestamps
    end
  end
end
