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
    version { 'version1' }
    external_identifier { FFaker::Name.first_name }
    repository_id { 1 }

    before(:create) do |obj|
      obj.repository ||= create(:repository)
    end
  end
end
