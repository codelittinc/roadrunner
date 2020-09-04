# frozen_string_literal: true

# == Schema Information
#
# Table name: servers
#
#  id                    :bigint           not null, primary key
#  link                  :string
#  supports_health_check :boolean
#  repository_id         :bigint
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  external_identifier   :string
#  active                :boolean          default(TRUE)
#  environment           :string
#  name                  :string
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
