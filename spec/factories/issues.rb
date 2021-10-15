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
#
FactoryBot.define do
  factory :issue do
    story_type { 'MyString' }
    state { 'MyString' }
    title { 'MyString' }
    users { nil }
    sprints { nil }
  end
end
