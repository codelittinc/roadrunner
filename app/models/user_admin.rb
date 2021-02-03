# frozen_string_literal: true

class UserAdmin < ApplicationRecord
  has_secure_password

  validates :username, presence: true
  validates :email, presence: true
end
