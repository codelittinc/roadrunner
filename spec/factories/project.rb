# frozen_string_literal: true

FactoryBot.define do
  factory :project do
    name { 'My Project' }

    client { association :client }
  end
end
