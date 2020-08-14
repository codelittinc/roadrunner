# == Schema Information
#
# Table name: repositories
#
#  id              :bigint           not null, primary key
#  alias           :string
#  deploy_type     :string
#  jira_project    :string
#  name            :string
#  supports_deploy :boolean
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  project_id      :bigint
#
# Indexes
#
#  index_repositories_on_project_id  (project_id)
#
class Repository < ApplicationRecord
  belongs_to :project
  has_many :servers
  has_one :slack_repository_info

  has_many :pull_requests

  TAG_DEPLOY_TYPE = 'tag'.freeze
  BRANCH_DEPLOY_TYPE = 'branch'.freeze

  validates :deploy_type, inclusion: { in: [TAG_DEPLOY_TYPE, BRANCH_DEPLOY_TYPE, nil] }

  def full_name
    "codelittinc/#{name}"
  end

  def github_link
    "https://github.com/#{full_name}"
  end

  def deploy_with_tag?
    deploy_type == TAG_DEPLOY_TYPE
  end
end
