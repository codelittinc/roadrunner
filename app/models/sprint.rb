# frozen_string_literal: true

# == Schema Information
#
# Table name: sprints
#
#  id          :bigint           not null, primary key
#  end_date    :datetime
#  name        :string
#  source      :string
#  start_date  :datetime
#  team        :string
#  time_frame  :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  customer_id :bigint
#
# Indexes
#
#  index_sprints_on_customer_id  (customer_id)
#
# Foreign Keys
#
#  fk_rails_...  (customer_id => customers.id)
#
class Sprint < ApplicationRecord
  has_many :issues, dependent: :destroy
  belongs_to :customer
end
