# frozen_string_literal: true

FactoryBot.define do
  factory :server do
    link { 'roadrunner.codelitt.dev' }

    before(:create) do |obj|
      obj.repository ||= create(:repository)
    end
  end
end
