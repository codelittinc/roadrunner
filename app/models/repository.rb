# frozen_string_literal: true

# == Schema Information
#
# Table name: repositories
#
#  id                  :bigint           not null, primary key
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  project_id          :bigint
#  deploy_type         :string
#  supports_deploy     :boolean
#  name                :string
#  jira_project        :string
#  owner               :string
#  source_control_type :string
#
class Repository < ApplicationRecord
  belongs_to :project, optional: true
  has_one :slack_repository_info, dependent: :destroy

  has_many :pull_requests
  has_many :branches
  has_many :applications

  accepts_nested_attributes_for :slack_repository_info

  TAG_DEPLOY_TYPE = 'tag'
  BRANCH_DEPLOY_TYPE = 'branch'

  validates :deploy_type, inclusion: { in: [TAG_DEPLOY_TYPE, BRANCH_DEPLOY_TYPE, nil] }
  validates :source_control_type, presence: true, inclusion: { in: %w[github azure] }
  validates :base_branch, presence: true

  DEPLOY_DEV_BRANCH = 'develop'
  DEPLOY_QA_BRANCH = 'qa'

  def deployment_branches?(base, head)
    [DEPLOY_QA_BRANCH,
     base_branch].include?(base) && [DEPLOY_DEV_BRANCH, DEPLOY_QA_BRANCH].include?(head)
  end

  def full_name
    "#{owner}/#{name}"
  end

  def github_link
    "https://github.com/#{full_name}"
  end

  def deploy_with_tag?
    deploy_type == TAG_DEPLOY_TYPE
  end

  def application_by_environment(environment)
    applications.find_by(environment:)
  end
end
