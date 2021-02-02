# frozen_string_literal: true

class DatabaseCredential < ApplicationRecord
  DEV_ENV = 'dev'
  QA_ENV = 'qa'
  PROD_ENV = 'prod'

  SUPPORTED_ENVS = [DEV_ENV, QA_ENV, PROD_ENV].freeze

  validates :env, presence: true, inclusion: { in: SUPPORTED_ENVS }
  validates :type, presence: true
  validates :name, presence: true, uniqueness: true
  validates :db_host, presence: true, uniqueness: true
  validates :db_user, presence: true
  validates :db_name, presence: true
  validates :db_password, presence: true
end
