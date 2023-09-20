# frozen_string_literal: true

# == Schema Information
#
# Table name: projects
#
#  id          :bigint           not null, primary key
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  slug        :string
#  customer_id :bigint
#  active      :boolean          default(TRUE)
#
class Project < ApplicationRecord
  belongs_to :customer
  has_many :repositories

  scope :active, -> { where(active: true) }
end
