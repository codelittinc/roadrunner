# frozen_string_literal: true

# == Schema Information
#
# Table name: external_resource_metadata
#
#  id         :bigint           not null, primary key
#  key        :string
#  value      :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :external_resource_metadata do
    key { 'MyString' }
    value { 'MyString' }
  end
end
