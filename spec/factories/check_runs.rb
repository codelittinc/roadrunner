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
FactoryBot.define do
  factory :check_run do
    state { 'success' }
    commit_sha { '1' }
  end
end
