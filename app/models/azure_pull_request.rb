# frozen_string_literal: true

# == Schema Information
#
# Table name: azure_pull_requests
#
#  id                :bigint           not null, primary key
#  source_control_id :string
#  pull_request_id   :bigint
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
class AzurePullRequest < ApplicationRecord
  has_one :pull_request, as: :source, dependent: :destroy

  validates :source_control_id, presence: true
  validates :pull_request, presence: true
end
