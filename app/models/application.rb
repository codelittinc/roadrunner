# frozen_string_literal: true

# == Schema Information
#
# Table name: applications
#
#  id                  :bigint           not null, primary key
#  environment         :string
#  version             :string
#  external_identifier :string
#  repository_id       :bigint           not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
class Application < ApplicationRecord
  belongs_to :repository

  has_one :server, dependent: :destroy
  has_many :server_incidents, dependent: :destroy

  validates :environment, presence: true
  validates :version, presence: true
  validates :external_identifier, presence: true, uniqueness: true
end
