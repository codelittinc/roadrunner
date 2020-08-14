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
require 'rails_helper'

RSpec.describe Project, type: :model do
  describe 'associations' do
    it { should have_many(:repositories) }
  end
end
