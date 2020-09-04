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
require 'rails_helper'

RSpec.describe ServerStatusCheck, type: :model do
  describe 'associations' do
    it { should belong_to(:server) }
  end
end
