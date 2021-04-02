# frozen_string_literal: true

FactoryBot.define do
  factory :server_incident do
    application { associate :application }
  end
end
