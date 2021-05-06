# frozen_string_literal: true

# == Schema Information
#
# Table name: application
#
#  id                  :bigint         not null, primary key
#  environment         :string
#  external_identifier :string
#  repository_id       :bigint         not null
#  created_at          :datetime       not null
#  updated_at          :datetime       not null
#
FactoryBot.define do
  factory :application do
    environment { 'dev' }
    repository { association :repository }

    transient do
      external_identifier { "v#{rand(100)}.#{rand(100)}.#{rand(100)}" }
    end

    before(:create) do |obj, evaluator|
      obj.external_identifiers << ExternalIdentifier.create(text: evaluator.external_identifier, application: obj) if obj.external_identifiers.size.zero?
    end

    trait :with_server do
      after :create do |application|
        create :server, application: application
      end
    end
  end
end
