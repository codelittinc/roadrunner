# frozen_string_literal: true

FactoryBot.define do
  factory :customer do
    name { 'Codelitt' }
    slack_api_key { '123456' }
  end
end
