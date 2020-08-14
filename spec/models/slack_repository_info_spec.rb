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
require 'rails_helper'

RSpec.describe SlackRepositoryInfo, type: :model do
  describe 'associations' do
    it { should belong_to(:repository) }
  end

  describe 'validations' do
    it { should validate_presence_of(:repository) }
  end
end
