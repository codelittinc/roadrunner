# frozen_string_literal: true

FactoryBot.define do
  factory :database_credential do
    env { 'env' }
    type { 'postgresql' }
    name { 'roadrunner' }
    db_host { 'MyString' }
    db_user { 'MyString' }
    db_name { 'MyString' }
    db_password { 'MyString' }
  end
end
