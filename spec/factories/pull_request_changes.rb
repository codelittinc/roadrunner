# == Schema Information
#
# Table name: pull_request_changes
#
#  id              :bigint           not null, primary key
#  pull_request_id :bigint           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
FactoryBot.define do
  factory :pull_request_change do
    pull_request { nil }
  end
end
