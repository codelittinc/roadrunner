# frozen_string_literal: true

# == Schema Information
#
# Table name: pull_request_reviews
#
#  id                :bigint           not null, primary key
#  state             :string
#  username          :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  backstage_user_id :integer
#  pull_request_id   :bigint           not null
#
# Indexes
#
#  index_pull_request_reviews_on_pull_request_id  (pull_request_id)
#
# Foreign Keys
#
#  fk_rails_...  (pull_request_id => pull_requests.id)
#
FactoryBot.define do
  factory :pull_request_review do
    state { 'MyString' }
    username { 'MyString' }
    pull_request { nil }
  end
end
