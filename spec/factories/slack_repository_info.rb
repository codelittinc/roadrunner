# frozen_string_literal: true

FactoryBot.define do
  factory :slack_repository_info do
    dev_group { '@website-devs' }
    dev_channel { 'feed-test-automations' }
    deploy_channel { 'feed-test-automations' }
    feed_channel { 'feed-test-automations' }
    repository
  end
end
