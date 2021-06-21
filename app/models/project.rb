# frozen_string_literal: true

# == Schema Information
#
# Table name: projects
#
#  id         :bigint           not null, primary key
#  name       :string
#  client_id  :bigint
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  slug       :string
#
class Project < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  belongs_to :client
  has_many :repositories
end
