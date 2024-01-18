# frozen_string_literal: true

# == Schema Information
#
# Table name: server_status_checks
#
#  id         :bigint           not null, primary key
#  code       :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  server_id  :bigint
#
# Indexes
#
#  index_server_status_checks_on_server_id  (server_id)
#
require 'rails_helper'

RSpec.describe ServerStatusCheck, type: :model do
  describe 'associations' do
    it { should belong_to(:server) }
  end
end
