# == Schema Information
#
# Table name: server_incidents
#
#  id                     :bigint           not null, primary key
#  message                :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  server_id              :bigint
#  server_status_check_id :bigint
#
# Indexes
#
#  index_server_incidents_on_server_id               (server_id)
#  index_server_incidents_on_server_status_check_id  (server_status_check_id)
#
require 'rails_helper'

RSpec.describe ServerIncident, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
