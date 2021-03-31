# frozen_string_literal: true

# == Schema Information
#
# Table name: application
#
#  id                  :bigint         not null, primary key
#  environment         :string
#  version             :string
#  external_identifier :string
#  repository_id       :bigint         not null
#  created_at          :datetime       not null
#  updated_at          :datetime       not null
#
FactoryBot.define do
  factory :application do
    environment { 'environment1' }
    version { "v#{rand(100)}.#{rand(100)}.#{rand(100)}" }
    external_identifier { "v#{rand(100)}.#{rand(100)}.#{rand(100)}" }
    repository { association :repository }
  end
end