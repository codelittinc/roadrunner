# frozen_string_literal: true

FactoryBot.define do
  factory :server do
    link { 'roadrunner.codelitt.dev' }

    before(:create) do |obj|
      obj.repository ||= create(:repository)
      obj.slack_repository_info ||= create(:slack_repository_info)
      obj.application ||= create(:application)
    end
  end
end
