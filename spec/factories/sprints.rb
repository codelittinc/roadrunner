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
FactoryBot.define do
  factory :sprint do
    number { '' }
    start_date { '2021-10-15 02:47:58' }
    end_date { '2021-10-15 02:47:58' }
    name { 'MyString' }
    time_frame { 'MyString' }
  end
end
