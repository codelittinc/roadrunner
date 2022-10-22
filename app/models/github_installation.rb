# frozen_string_literal: true

class GithubInstallation < ApplicationRecord
  belongs_to :organization

  validates :installation_id, presence: true
end
