# frozen_string_literal: true

# == Schema Information
#
# Table name: organizations
#
#  id                :bigint           not null, primary key
#  notifications_id  :string
#  name              :string
#  notifications_key :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
FactoryBot.define do
  factory :organization do
    notifications_id { 'MyString' }
    name { 'MyString' }
    notifications_key { 'MyString' }
  end
end
