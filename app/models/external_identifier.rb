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
class ExternalIdentifier < ApplicationRecord
  belongs_to :application

  validates :text, presence: true
end
