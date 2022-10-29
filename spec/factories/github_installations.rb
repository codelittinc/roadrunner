# frozen_string_literal: true

FactoryBot.define do
  factory :github_installation do
    organization { association :organization }
    installation_id { '30421922' }
  end
end
