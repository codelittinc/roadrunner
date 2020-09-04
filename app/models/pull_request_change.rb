# frozen_string_literal: true

# == Schema Information
#
# Table name: pull_request_changes
#
#  id              :bigint           not null, primary key
#  pull_request_id :bigint           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class PullRequestChange < ApplicationRecord
  belongs_to :pull_request
end
