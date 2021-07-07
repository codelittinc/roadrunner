# frozen_string_literal: true

# == Schema Information
#
# Table name: external_identifiers
#
#  id             :bigint           not null, primary key
#  text           :string
#  application_id :bigint
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class ExternalIdentifier < ApplicationRecord
  belongs_to :application

  validates :text, presence: true
end
