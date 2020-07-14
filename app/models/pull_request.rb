class PullRequest < ApplicationRecord
  belongs_to :user
  belongs_to :repository

  has_many :commits, dependent: :destroy
  has_one :slack_message, dependent: :destroy

  validates :head, presence: true
  validates :base, presence: true

  validates :github_id, presence: true
  validates :title, presence: true
  validates :state, presence: true
  validates :owner, presence: true

  DEPLOY_DEV_BRANCH_LEGACY = 'dev'.freeze
  DEPLOY_DEV_BRANCH = 'develop'.freeze
  DEPLOY_QA_BRANCH = 'qa'.freeze
  DEPLOY_PROD_BRANCH = 'master'.freeze

  def self.deployment_branches?(base, head)
    (base == DEPLOY_QA_BRANCH || base == DEPLOY_PROD_BRANCH) && (head == DEPLOY_DEV_BRANCH || head == DEPLOY_QA_BRANCH || head == DEPLOY_DEV_BRANCH_LEGACY)
  end

  def github_link
    "https://github.com/codelittinc/#{repository.name}/pull/#{github_id}"
  end

  state_machine :state, initial: :open do
    event :merge! do
      transition open: :merged
    end

    event :cancel! do
      transition open: :cancelled
    end
  end
end
