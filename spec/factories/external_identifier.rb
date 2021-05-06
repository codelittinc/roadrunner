# frozen_string_literal: true

FactoryBot.define do
  factory :external_identifier do
    text { "v#{rand(100)}.#{rand(100)}.#{rand(100)}" }
  end
end
