# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    slack { 'kaiomagalhaes' }
    customer { association :customer }
  end
end
