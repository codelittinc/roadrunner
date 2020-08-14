class CheckRun < ApplicationRecord
  validates :state, presence: true

  FAILURE_STATE = 'failure'.freeze
  SUCCESS_STATE = 'success'.freeze
  PENDING_STATE = 'pending'.freeze
end
