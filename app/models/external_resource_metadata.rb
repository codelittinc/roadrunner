# frozen_string_literal: true

# == Schema Information
#
# Table name: external_resource_metadata
#
#  id             :bigint           not null, primary key
#  key            :string
#  value          :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class ExternalResourceMetadata < ApplicationRecord
  validates :key, presence: true
  validates :value, presence: true
end
