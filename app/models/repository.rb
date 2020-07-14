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
