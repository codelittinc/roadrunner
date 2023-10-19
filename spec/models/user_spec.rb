# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                  :bigint           not null, primary key
#  github              :string
#  jira                :string
#  slack               :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  azure               :string
#  azure_devops_issues :string
#  customer_id         :bigint
#  name                :string
#  active              :boolean          default(TRUE)
#
require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:pull_requests) }
  end
end
