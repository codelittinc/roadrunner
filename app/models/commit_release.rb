# frozen_string_literal: true

# == Schema Information
#
# Table name: commit_releases
#
#  id         :bigint           not null, primary key
#  commit_id  :bigint
#  release_id :bigint
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class CommitRelease < ApplicationRecord
  belongs_to :commit
  belongs_to :release
end
