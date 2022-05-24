# frozen_string_literal: true

# == Schema Information
#
# Table name: sprints
#
#  id          :bigint           not null, primary key
#  start_date  :datetime
#  end_date    :datetime
#  name        :string
#  time_frame  :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  team        :string
#  customer_id :bigint
#
class Sprint < ApplicationRecord
  has_many :issues, dependent: :destroy
  belongs_to :customer
end
