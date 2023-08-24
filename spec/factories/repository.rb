# frozen_string_literal: true

FactoryBot.define do
  factory :repository do
    name { 'roadrunner-repository-test' }
    owner { 'codelittinc' }
    source_control_type { 'github' }
    deploy_type { 'tag' }
    supports_deploy { true }
    project { association :project }
    active { true }
    base_branch { 'master' }

    after(:create) do |obj|
      create(:slack_repository_info, repository: obj)
    end
  end
end
