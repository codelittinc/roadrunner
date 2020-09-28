# frozen_string_literal: true

FactoryBot.define do
  factory :server_incident do
    before(:create) do |obj|
      obj.server ||= create(:server)
    end
  end
end
