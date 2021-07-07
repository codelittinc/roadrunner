# frozen_string_literal: true

# == Schema Information
#
# Table name: azure_pull_requests
#
#  id                :bigint           not null, primary key
#  source_control_id :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
class AzurePullRequest < ApplicationRecord
  has_one :pull_request, as: :source, dependent: :destroy

  validates :source_control_id, presence: true
  validates :pull_request, presence: true

  def link
    repository = pull_request.repository
    # @TODO: find a way to name the company name here to avoid hard coding: AY-InnovationCenter
    "https://dev.azure.com/AY-InnovationCenter/#{repository&.owner}/_git/#{repository&.name}/pullrequest/#{source_control_id}"
  end
end
