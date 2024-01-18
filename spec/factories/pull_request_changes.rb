# frozen_string_literal: true

# == Schema Information
#
# Table name: pull_request_changes
#
#  id              :bigint           not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  pull_request_id :bigint           not null
#
# Indexes
#
#  index_pull_request_changes_on_pull_request_id  (pull_request_id)
#
# Foreign Keys
#
#  fk_rails_...  (pull_request_id => pull_requests.id)
#
FactoryBot.define do
  factory :pull_request_change do
    pull_request { nil }
  end
end
