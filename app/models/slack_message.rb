# == Schema Information
#
# Table name: slack_messages
#
#  id              :bigint           not null, primary key
#  text            :string
#  ts              :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  pull_request_id :bigint
#
# Indexes
#
#  index_slack_messages_on_pull_request_id  (pull_request_id)
#
class SlackMessage < ApplicationRecord
  belongs_to :pull_request, optional: true
  validates :ts, presence: true
end
