# frozen_string_literal: true

# == Schema Information
#
# Table name: commits
#
#  id              :bigint           not null, primary key
#  author_email    :string
#  author_name     :string
#  message         :string
#  sha             :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  pull_request_id :bigint
#
# Indexes
#
#  index_commits_on_pull_request_id  (pull_request_id)
#
class Commit < ApplicationRecord
  belongs_to :pull_request
  has_many :commit_releases, dependent: :destroy
  has_many :releases, through: :commit_releases

  validates :sha, presence: true
  validates :author_name, presence: true

  scope :by_repository, lambda { |repository|
    joins(:pull_request).where(pull_requests: { repository: })
  }
end
