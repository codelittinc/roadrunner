# frozen_string_literal: true

FactoryBot.define do
  factory :user_admin do
    name { 'MyString' }
    password_digest { 'MyString' }
  end
end
