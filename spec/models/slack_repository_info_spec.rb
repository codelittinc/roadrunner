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
require 'rails_helper'

RSpec.describe SlackRepositoryInfo, type: :model do
  describe 'associations' do
    it { should belong_to(:repository) }
  end

  describe 'validations' do
    it { should validate_presence_of(:repository) }
  end
end
