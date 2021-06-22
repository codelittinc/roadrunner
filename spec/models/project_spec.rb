# frozen_string_literal: true

# == Schema Information
#
# Table name: projects
#
#  id         :bigint           not null, primary key
#  name       :string
#  customer_id  :bigint
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  slug       :string
#
require 'rails_helper'

RSpec.describe Project, type: :model do
  describe 'associations' do
    it { should have_many(:repositories) }
    it { should belong_to(:customer) }
  end
end
