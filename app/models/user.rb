# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                  :bigint           not null, primary key
#  github              :string
#  jira                :string
#  slack               :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  azure               :string
#  azure_devops_issues :string
#  customer_id         :bigint
#  name                :string
#  active              :boolean          default(TRUE)
#
class User < ApplicationRecord
  include PgSearch::Model

  pg_search_scope :search_by_term, against: %i[jira slack github azure azure_devops_issues]

  has_many :pull_requests
  belongs_to :customer
end
