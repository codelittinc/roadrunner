# frozen_string_literal: true

FactoryBot.define do
  factory :release do
    version { "v#{rand(100)}.#{rand(100)}.#{rand(100)}" }
  end
end
