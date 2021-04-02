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
FactoryBot.define do
  factory :user_admin do
    name { 'MyString' }
    password_digest { 'MyString' }
  end
end
