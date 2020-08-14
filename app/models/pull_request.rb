# == Schema Information
#
# Table name: pull_requests
#
#  id            :bigint           not null, primary key
#  base          :string
#  ci_state      :string
#  description   :string
#  head          :string
#  owner         :string
#  state         :string
#  title         :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  github_id     :integer
#  repository_id :bigint
#  user_id       :bigint
#
# Indexes
#
#  index_pull_requests_on_repository_id  (repository_id)
#  index_pull_requests_on_user_id        (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (repository_id => repositories.id)
#  fk_rails_...  (user_id => users.id)
#
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
    "https://github.com/codelittinc/#{repository&.name}/pull/#{github_id}"
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
