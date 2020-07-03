# frozen_string_literal: true

FactoryBot.define do
  factory :repository do
    deploy_type { 'tag' }
    supports_deploy {true}

    before(:create) do |obj|
      obj.project ||= create(:project)
    end
  end
end
