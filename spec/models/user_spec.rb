# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                  :bigint           not null, primary key
#  active              :boolean          default(TRUE)
#  azure               :string
#  azure_devops_issues :string
#  github              :string
#  jira                :string
#  name                :string
#  slack               :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  customer_id         :bigint
#
# Indexes
#
#  index_users_on_customer_id  (customer_id)
#
# Foreign Keys
#
#  fk_rails_...  (customer_id => customers.id)
#
require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:pull_requests) }
  end
end
