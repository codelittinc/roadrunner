# frozen_string_literal: true

# == Schema Information
#
# Table name: pull_requests
#
#  id            :bigint           not null, primary key
#  head          :string
#  base          :string
#  source_control_id     :integer
#  title         :string
#  description   :string
#  state         :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  repository_id :bigint
#  user_id       :bigint
#  ci_state      :string
#
class PullRequest < ApplicationRecord
  belongs_to :user
  belongs_to :repository

  has_many :commits, dependent: :destroy
  has_many :pull_request_reviews, dependent: :destroy
  has_one :slack_message, dependent: :destroy
  has_many :pull_request_changes, dependent: :destroy
  has_one :branch, dependent: :nullify
  has_many :check_runs, through: :branch

  # @TODO: rename to source_control
  belongs_to :source, polymorphic: true

  validates :head, presence: true
  validates :base, presence: true
  validates :title, presence: true
  validates :state, presence: true

  DEPLOY_DEV_BRANCH_LEGACY = 'dev'
  DEPLOY_DEV_BRANCH = 'develop'
  DEPLOY_QA_BRANCH = 'qa'
  DEPLOY_PROD_BRANCH = 'master'

  def self.deployment_branches?(base, head)
    (base == DEPLOY_QA_BRANCH || base == DEPLOY_PROD_BRANCH) && (head == DEPLOY_DEV_BRANCH || head == DEPLOY_QA_BRANCH || head == DEPLOY_DEV_BRANCH_LEGACY)
  end

  delegate :link, to: :source
  delegate :source_control_id, to: :source

  def self.by_repository_and_source_control_id(repository, source_control_id)
    [GithubPullRequest, AzurePullRequest].lazy.map do |clazz|
      clazz.joins(:pull_request).find_by(source_control_id: source_control_id, pull_request: {repository_id: repository&.id})
    end.find(&:itself)&.pull_request
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
