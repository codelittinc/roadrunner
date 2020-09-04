# frozen_string_literal: true

# == Schema Information
#
# Table name: slack_messages
#
#  id              :bigint           not null, primary key
#  ts              :string
#  pull_request_id :bigint
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  text            :string
#
class SlackMessage < ApplicationRecord
  belongs_to :pull_request, optional: true
  validates :ts, presence: true
end
