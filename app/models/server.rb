# == Schema Information
#
# Table name: servers
#
#  id                    :bigint           not null, primary key
#  link                  :string
#  supports_health_check :boolean
#  repository_id         :bigint
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  external_identifier   :string
#  active                :boolean          default(TRUE)
#  environment           :string
#  name                  :string
#
class Server < ApplicationRecord
  belongs_to :repository

  validates :link, presence: true
  validates :repository, presence: true
  validates :name, presence: true

  has_one :slack_repository_info, through: :repository
  has_many :server_incidents
  has_many :server_status_checks
end
