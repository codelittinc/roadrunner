# frozen_string_literal: true

# == Schema Information
#
# Table name: azure_pull_requests
#
#  id              :bigint           not null, primary key
#  azure_id        :string
#  pull_request_id :bigint
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class AzurePullRequest < ApplicationRecord
  include SourceControl

  belongs_to :pull_request

  validates :azure_id, presence: true
  validates :pull_request, presence: true
end
