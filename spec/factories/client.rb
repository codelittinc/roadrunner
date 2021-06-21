# frozen_string_literal: true

FactoryBot.define do
  factory :client do
    name { 'Codelitt' }
    slack_api_key { '123456' }
  end
end
