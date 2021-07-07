# frozen_string_literal: true

# == Schema Information
#
# Table name: releases
#
#  id             :bigint           not null, primary key
#  version        :string
#  application_id :bigint
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  deploy_status  :string
#
class Release < ApplicationRecord
  belongs_to :application
  has_many :commit_releases, dependent: :destroy
  has_many :commits, through: :commit_releases

  validates :version, presence: true
  validates :deploy_status, inclusion: {
    in: ['success', 'failure', nil]
  }
end
