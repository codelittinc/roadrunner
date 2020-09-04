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
class PullRequestReview < ApplicationRecord
  belongs_to :pull_request

  validates :username, presence: true
  validates :state, presence: true

  REVIEW_STATE_CHANGES_REQUESTED = 'changes_requested'
end
