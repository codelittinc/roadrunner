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
#  source      :string
#
require 'rails_helper'

RSpec.describe Sprint, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
