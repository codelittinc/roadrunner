# frozen_string_literal: true

# == Schema Information
#
# Table name: issues
#
#  id           :bigint           not null, primary key
#  state        :string
#  story_points :decimal(, )
#  story_type   :string
#  tags         :string
#  title        :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  sprint_id    :bigint
#  user_id      :bigint
#
# Indexes
#
#  index_issues_on_sprint_id  (sprint_id)
#  index_issues_on_user_id    (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (sprint_id => sprints.id)
#  fk_rails_...  (user_id => users.id)
#
class Issue < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :sprint
end
