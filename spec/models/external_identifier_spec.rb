# frozen_string_literal: true

# == Schema Information
#
# Table name: external_identifiers
#
#  id             :bigint           not null, primary key
#  text           :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  application_id :bigint
#
# Indexes
#
#  index_external_identifiers_on_application_id  (application_id)
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
