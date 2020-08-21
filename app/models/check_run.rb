# == Schema Information
#
# Table name: check_runs
#
#  id         :bigint           not null, primary key
#  state      :string
#  commit_sha :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class CheckRun < ApplicationRecord
  validates :state, presence: true

  FAILURE_STATE = 'failure'.freeze
  SUCCESS_STATE = 'success'.freeze
  PENDING_STATE = 'pending'.freeze
end
