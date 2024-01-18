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
require 'rails_helper'

RSpec.describe CheckRun, type: :model do
  describe 'should validate the props' do
    it { is_expected.to validate_presence_of(:state) }
  end
end
