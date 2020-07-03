# frozen_string_literal: true

FactoryBot.define do
  factory :pull_request do
    head { 'feat/test' }
    base { 'master' }
    github_id { 1 }
    title { 'my nice PR' }
    description { 'my nice PR' }
    owner { 'codelittinc' }

    before(:create) do |obj|
      obj.user ||= create(:user)
      obj.repository ||= create(:repository)
    end
  end
end
