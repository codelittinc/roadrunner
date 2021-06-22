# frozen_string_literal: true

FactoryBot.define do
  factory :project do
    name { 'My Project' }

    customer { association :customer }
  end
end
