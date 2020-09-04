# frozen_string_literal: true

# == Schema Information
#
# Table name: server_status_checks
#
#  id         :bigint           not null, primary key
#  code       :integer
#  server_id  :bigint
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class ServerStatusCheck < ApplicationRecord
  belongs_to :server

  # @TODO: remove or turn into a constant
  def incident_type
    'status_verification'
  end
end
