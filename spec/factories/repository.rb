# frozen_string_literal: true

FactoryBot.define do
  factory :repository do
    name { 'roadrunner-repository-test' }
    owner { 'codelittinc' }
    deploy_type { 'tag' }
    supports_deploy { true }
    project { association :project }

    after(:create) do |obj|
      create(:slack_repository_info, repository: obj)
    end
  end
end
