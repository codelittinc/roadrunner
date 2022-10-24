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
  has_many :issues
  belongs_to :customer

  def self.find_existing_user(user)
    find_duplicates(user).first
  end

  def self.find_duplicates(user)
    User.all.select do |curr_user|
      result = (
        (user.github.present? && user.github == curr_user.github) ||
        (user.azure.present? && user.azure == curr_user.azure) ||
        (user.azure_devops_issues.present? && user.azure_devops_issues == curr_user.azure_devops_issues) ||
        (user.jira.present? && user.jira == curr_user.jira) ||
        (user.name.present? && curr_user.name.present? && (!(user.name =~ /#{curr_user.name}/).nil? || !(curr_user.name =~ /#{user.name}/).nil?))
      )

      result
    end
  end

  def self.find_all_duplicates
    users = all.order(:id)
    duplicates = []

    users.each do |user|
      dups = find_duplicates(user)
      duplicates << dups unless dups.size < 2
    end

    duplicates
  end
end
