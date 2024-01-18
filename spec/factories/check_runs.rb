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
FactoryBot.define do
  factory :check_run do
    state { 'success' }
    commit_sha { '1' }
  end
end
