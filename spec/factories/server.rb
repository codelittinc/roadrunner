# frozen_string_literal: true

FactoryBot.define do
  factory :server do
    name { 'my cool server' }
    link { 'roadrunner.codelitt.dev' }
    environment { 'prod' }

    before(:create) do |obj|
      obj.repository ||= create(:repository)
    end
  end
end
