# frozen_string_literal: true

FactoryBot.define do
  factory :repository do
    name { 'roadrunner-repository-test' }
    friendly_name { FFaker::Name.name }
    owner { 'codelittinc' }
    source_control_type { 'github' }
    deploy_type { 'tag' }
    supports_deploy { true }
    project { association :project }
    active { true }

    after(:create) do |obj|
      create(:slack_repository_info, repository: obj)
    end
  end
end
