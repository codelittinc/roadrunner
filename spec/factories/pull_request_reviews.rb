# frozen_string_literal: true

# == Schema Information
#
# Table name: pull_request_reviews
#
#  id              :bigint           not null, primary key
#  state           :string
#  username        :string
#  pull_request_id :bigint           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
FactoryBot.define do
  factory :pull_request_review do
    state { 'MyString' }
    username { 'MyString' }
    pull_request { nil }
  end
end
