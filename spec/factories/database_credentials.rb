# frozen_string_literal: true

# == Schema Information
#
# Table name: database_credentials
#
#  id            :bigint           not null, primary key
#  env           :string
#  database_type :string
#  name          :string
#  db_host       :string
#  db_user       :string
#  db_name       :string
#  db_password   :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
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
