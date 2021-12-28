# frozen_string_literal: true

# == Schema Information
#
# Table name: slack_repository_infos
#
#  id             :bigint           not null, primary key
#  deploy_channel :string
#  repository_id  :bigint           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  dev_channel    :string
#  dev_group      :string
#  feed_channel   :string
#
class SlackRepositoryInfo < ApplicationRecord
  belongs_to :repository
end
