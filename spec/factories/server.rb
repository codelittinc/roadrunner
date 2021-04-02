# frozen_string_literal: true

FactoryBot.define do
  factory :server do
    link { 'roadrunner.codelitt.dev' }
    application { association :application }
    environment { 'prod' }
  end
end
