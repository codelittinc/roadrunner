# frozen_string_literal: true

FactoryBot.define do
  factory :pull_request do
    head { 'feat/test' }
    base { 'master' }
    title { 'my nice PR' }
    description { 'my nice PR' }
    repository
    slack_message

    transient do
      source_control_id { 1 }
      source_control_type { 'github' }
    end

    before(:create) do |obj, evaluator|
      clazz = evaluator.source_control_type == 'github' ? GithubPullRequest : AzurePullRequest
      obj.source = clazz.create(source_control_id: evaluator.source_control_id, pull_request: obj) unless obj.source
    end
  end
end
