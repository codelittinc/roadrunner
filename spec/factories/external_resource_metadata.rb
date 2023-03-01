# frozen_string_literal: true

# == Schema Information
#
# Table name: external_resource_metadata
#
#  id             :bigint           not null, primary key
#  key            :string
#  value          :string
#
FactoryBot.define do
  factory :external_resource_metadata do
    key { 'MyString' }
    value { 'MyString' }
  end
end
