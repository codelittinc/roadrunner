# frozen_string_literal: true

# == Schema Information
#
# Table name: organizations
#
#  id                :bigint           not null, primary key
#  notifications_id  :string
#  name              :string
#  notifications_key :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
class Organization < ApplicationRecord
  has_many :github_installations, dependent: :destroy

  validates :notifications_id, presence: true
  validates :name, presence: true
  validates :notifications_key, presence: true
end
