# == Schema Information
#
# Table name: projects
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  slug       :string
#
class Project < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :repositories
end
