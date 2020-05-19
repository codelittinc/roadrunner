class Repository < ApplicationRecord
  belongs_to :project
  has_many :servers
  has_one :slack_repository_info

  TAG_DEPLOY_TYPE = 'tag'
  BRANCH_DEPLOY_TYPE = 'branch'

  validates :deploy_type, inclusion: { in: [TAG_DEPLOY_TYPE, BRANCH_DEPLOY_TYPE, nil] }

  def deploy_with_tag?
    deploy_type == TAG_DEPLOY_TYPE
  end
end
