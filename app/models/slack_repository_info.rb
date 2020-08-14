# == Schema Information
#
# Table name: slack_repository_infos
#
#  id             :bigint           not null, primary key
#  deploy_channel :string
#  dev_channel    :string
#  dev_group      :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  repository_id  :bigint           not null
#
# Indexes
#
#  index_slack_repository_infos_on_repository_id  (repository_id)
#
# Foreign Keys
#
#  fk_rails_...  (repository_id => repositories.id)
#
class SlackRepositoryInfo < ApplicationRecord
  belongs_to :repository

  validates :repository, presence: true
end
