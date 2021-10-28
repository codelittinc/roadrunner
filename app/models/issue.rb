# frozen_string_literal: true

# == Schema Information
#
# Table name: issues
#
#  id           :bigint           not null, primary key
#  story_type   :string
#  state        :string
#  title        :string
#  story_points :decimal(, )
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  sprint_id    :bigint
#  user_id      :bigint
#  tags         :string
#
class Issue < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :sprint
end
