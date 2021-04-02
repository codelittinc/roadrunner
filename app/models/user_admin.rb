# frozen_string_literal: true

# == Schema Information
#
# Table name: user_admins
#
#  id              :bigint           not null, primary key
#  username        :string
#  email           :string
#  password_digest :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class UserAdmin < ApplicationRecord
  has_secure_password

  validates :username, presence: true
  validates :email, presence: true
end
