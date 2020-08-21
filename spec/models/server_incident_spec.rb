# == Schema Information
#
# Table name: server_incidents
#
#  id                     :bigint           not null, primary key
#  message                :string
#  server_id              :bigint
#  server_status_check_id :bigint
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
require 'rails_helper'

RSpec.describe ServerIncident, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
