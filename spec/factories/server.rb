# frozen_string_literal: true

FactoryBot.define do
  factory :server do
    link { 'roadrunner.codelitt.dev' }
    environment { 'prod' }

    before :create do |server|
      server.application ||= create :application
    end
  end
end
