# == Schema Information
#
# Table name: servers
#
#  id                    :bigint           not null, primary key
#  active                :boolean          default(TRUE)
#  alias                 :string
#  environment           :string
#  link                  :string
#  supports_health_check :boolean
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  repository_id         :bigint
#
# Indexes
#
#  index_servers_on_repository_id  (repository_id)
#
class Server < ApplicationRecord
  belongs_to :repository

  validates :link, presence: true
  validates :repository, presence: true

  has_one :slack_repository_info, through: :repository
  has_many :server_incidents
  has_many :server_status_checks
end
