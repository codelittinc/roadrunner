# == Schema Information
#
# Table name: projects
#
#  id         :bigint           not null, primary key
#  name       :string
#  slug       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_projects_on_slug  (slug) UNIQUE
#
class Project < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :repositories
end
