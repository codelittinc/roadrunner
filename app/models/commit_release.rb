# frozen_string_literal: true

# == Schema Information
#
# Table name: commit_releases
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  commit_id  :bigint
#  release_id :bigint
#
# Indexes
#
#  index_commit_releases_on_commit_id   (commit_id)
#  index_commit_releases_on_release_id  (release_id)
#
class CommitRelease < ApplicationRecord
  belongs_to :commit
  belongs_to :release
end
