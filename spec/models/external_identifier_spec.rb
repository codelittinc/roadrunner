# frozen_string_literal: true

# == Schema Information
#
# Table name: external_identifier
#
#  id             :bigint           not null, primary key
#  text           :string
#  application_id :bigint
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
require 'rails_helper'

RSpec.describe ExternalIdentifier, type: :model do
  describe 'associations' do
    it { should belong_to(:application) }
  end

  describe 'validations' do
    it { should validate_presence_of(:text) }
  end
end
