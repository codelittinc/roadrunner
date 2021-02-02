# frozen_string_literal: true

FactoryBot.define do
  factory :database_credential do
    env { 'dev' }
    database_type { 'postgresql' }
    name { 'roadrunner dev' }
    db_host { 'MyString' }
    db_user { 'MyString' }
    db_name { 'MyString' }
    db_password { 'MyString' }
  end
end
