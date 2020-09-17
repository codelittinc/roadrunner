# frozen_string_literal: true

# == Schema Information
#
# Table name: check_runs
#
#  id         :bigint           not null, primary key
#  state      :string
#  commit_sha :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  branch_id  :bigint
#
class CheckRun < ApplicationRecord
  validates :state, presence: true

  belongs_to :branch
  delegate :pull_request, to: :branch, allow_nil: true

  FAILURE_STATE = 'failure'
  SUCCESS_STATE = 'success'
  PENDING_STATE = 'pending'
end
