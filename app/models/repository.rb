# frozen_string_literal: true

# == Schema Information
#
# Table name: repositories
#
#  id              :bigint           not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  project_id      :bigint
#  deploy_type     :string
#  supports_deploy :boolean
#  name            :string
#  jira_project    :string
#  alias           :string
#  owner           :string
#
class Repository < ApplicationRecord
  belongs_to :project
  has_one :slack_repository_info

  has_many :pull_requests
  has_many :branches
  has_many :applications

  TAG_DEPLOY_TYPE = 'tag'
  BRANCH_DEPLOY_TYPE = 'branch'

  validates :deploy_type, inclusion: { in: [TAG_DEPLOY_TYPE, BRANCH_DEPLOY_TYPE, nil] }

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
    applications.find_by(environment: environment)
  end
end
