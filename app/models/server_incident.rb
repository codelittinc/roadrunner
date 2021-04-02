# frozen_string_literal: true

# == Schema Information
#
# Table name: server_incidents
#
#  id                     :bigint           not null, primary key
#  message                :string
#  server_status_check_id :bigint
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  state                  :string
#  slack_message_id       :bigint
#  application_id         :integer
#
class ServerIncident < ApplicationRecord
  belongs_to :application

  belongs_to :server_status_check, optional: true
  belongs_to :slack_message, optional: true

  validates :state, presence: true

  has_many :server_incident_instances, dependent: :destroy

  INCIDENT_ERROR = 'error'
  INCIDENT_WARNING = 'warning'
  REGEX_PROJECT_IN_INCIDENT_MESSAGE = /(?<=\|)[^.*]+(?=>)/

  def incident_type
    server_status_check ? INCIDENT_ERROR : INCIDENT_WARNING
  end

  scope :open_incidents, -> { with_state(:open, :in_progress) }

  state_machine :state, initial: :open do
    event :in_progress! do
      transition open: :in_progress
    end

    event :complete! do
      transition %i[open in_progress] => :completed
    end
  end
end
