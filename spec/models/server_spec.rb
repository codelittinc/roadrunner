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
require 'rails_helper'

RSpec.describe Server, type: :model do
  describe 'associations' do
    it { should belong_to(:repository) }
  end

  describe 'validations' do
    it { should validate_presence_of(:link) }
    it { should validate_presence_of(:repository) }
  end
end
