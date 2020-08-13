# frozen_string_literal: true

FactoryBot.define do
  factory :slack_repository_info do
    dev_group { '@batman' }
    dev_channel { 'dev-test-automations' }
    deploy_channel { 'deploy-test-automations' }
    deploy_channel { 'feed-test-automations' }
  end
end
