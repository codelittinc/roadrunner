# frozen_string_literal: true

# == Schema Information
#
# Table name: check_runs
#
#  id         :bigint           not null, primary key
#  commit_sha :string
#  state      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  branch_id  :bigint
#
# Indexes
#
#  index_check_runs_on_branch_id  (branch_id)
#
# Foreign Keys
#
#  fk_rails_...  (branch_id => branches.id)
#
class CheckRun < ApplicationRecord
  # @TODO: add repository reference
  validates :state, presence: true

  belongs_to :branch
  delegate :pull_request, to: :branch, allow_nil: true

  FAILURE_STATE = 'failure'
  SUCCESS_STATE = 'success'
  PENDING_STATE = 'pending'

  SUPPORTED_STATES = [SUCCESS_STATE, FAILURE_STATE, PENDING_STATE].freeze
end
