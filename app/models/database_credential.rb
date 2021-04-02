# frozen_string_literal: true

# == Schema Information
#
# Table name: database_credentials
#
#  id            :bigint           not null, primary key
#  env           :string
#  database_type :string
#  name          :string
#  db_host       :string
#  db_user       :string
#  db_name       :string
#  db_password   :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class DatabaseCredential < ApplicationRecord
  DEV_ENV = 'dev'
  QA_ENV = 'qa'
  PROD_ENV = 'prod'

  SUPPORTED_ENVS = [DEV_ENV, QA_ENV, PROD_ENV].freeze

  validates :env, presence: true, inclusion: { in: SUPPORTED_ENVS }
  validates :database_type, presence: true
  validates :name, presence: true, uniqueness: true
  validates :db_host, presence: true, uniqueness: true
  validates :db_user, presence: true
  validates :db_name, presence: true
  validates :db_password, presence: true
end
