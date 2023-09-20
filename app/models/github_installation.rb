# frozen_string_literal: true

# == Schema Information
#
# Table name: github_installations
#
#  id              :bigint           not null, primary key
#  installation_id :string
#  organization_id :bigint
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  name            :string
#
class GithubInstallation < ApplicationRecord
  belongs_to :organization

  validates :installation_id, presence: true
end
