# frozen_string_literal: true

# == Schema Information
#
# Table name: branches
#
#  id              :bigint           not null, primary key
#  name            :string
#  repository_id   :bigint           not null
#  pull_request_id :bigint
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
FactoryBot.define do
  factory :branch do
    name { 'branch1' }

    before(:create) do |obj|
      obj.repository ||= create(:repository)
    end
  end
end
