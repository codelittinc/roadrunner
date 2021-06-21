# frozen_string_literal: true

# == Schema Information
#
# Table name: clients
#
#  id             :bigint           not null, primary key
#  name           :string
#  slack_api_key  :string
#  github_api_key :string
#  sentry_name    :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class Client < ApplicationRecord
  validates :name, presence: true

  has_many :projects, dependent: :destroy
end
