# frozen_string_literal: true

FactoryBot.define do
  factory :pull_request do
    head { 'feat/test' }
    base { 'master' }
    source_control_id { 1 }
    title { 'my nice PR' }
    description { 'my nice PR' }
    user
    repository
    slack_message

    before(:create) do |obj|
      # @TODO: update this to be dependent on the type of the request
      obj.source = GithubPullRequest.create(source_control_id: obj.source_control_id, pull_request: obj) unless obj.source
    end
  end
end
