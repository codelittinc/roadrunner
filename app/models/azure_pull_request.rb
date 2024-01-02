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
    metadata = repository.external_project.metadata
    azure_project_name = metadata['azure_project_name']
    azure_owner = metadata['azure_owner']

    # @TODO: find a way to name the company name here to avoid hard coding: AY-InnovationCenter
    # it sounds like our concept of owner in github is different from it in Azure. In azure it should be called project name
    "https://dev.azure.com/#{azure_owner}/#{azure_project_name}/_git/#{repository&.name}/pullrequest/#{source_control_id}"
  end
end
