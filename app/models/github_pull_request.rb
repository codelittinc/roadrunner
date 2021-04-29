# frozen_string_literal: true

# == Schema Information
#
# Table name: github_pull_requests
#
#  id              :bigint           not null, primary key
#  github_id       :string
#  pull_request_id :bigint
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class GithubPullRequest < ApplicationRecord
  has_one :pull_request, as: :source, dependent: :destroy

  validates :github_id, presence: true
  validates :pull_request, presence: true
end
