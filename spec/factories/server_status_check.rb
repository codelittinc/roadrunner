# frozen_string_literal: true

FactoryBot.define do
  factory :server_status_check do
    code { 200 }
    before(:create) do |obj|
      obj.server ||= create(:server)
    end
  end
end
