# frozen_string_literal: true

# == Schema Information
#
# Table name: github_pull_requests
#
#  id                :bigint           not null, primary key
#  source_control_id :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
class GithubPullRequest < ApplicationRecord
  has_one :pull_request, as: :source, dependent: :destroy

  validates :source_control_id, presence: true
  validates :pull_request, presence: true

  def link
    repository = pull_request.repository
    "https://github.com/#{repository&.owner}/#{repository&.name}/pull/#{source_control_id}"
  end
end
