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
class PullRequestReview < ApplicationRecord
  belongs_to :pull_request

  validates :username, presence: true
  validates :state, presence: true
  validates :backstage_user_id, presence: true

  REVIEW_STATE_CHANGES_REQUESTED = 'changes_requested'
end
