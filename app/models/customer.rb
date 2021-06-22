# frozen_string_literal: true

# == Schema Information
#
# Table name: customers
#
#  id             :bigint           not null, primary key
#  name           :string
#  slack_api_key  :string
#  github_api_key :string
#  sentry_name    :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class Customer < ApplicationRecord
  validates :name, presence: true

  has_many :projects, dependent: :destroy
end
