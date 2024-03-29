# frozen_string_literal: true

# == Schema Information
#
# Table name: releases
#
#  id             :bigint           not null, primary key
#  deploy_status  :string
#  version        :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  application_id :bigint
#
# Indexes
#
#  index_releases_on_application_id  (application_id)
#
# Foreign Keys
#
#  fk_rails_...  (application_id => applications.id)
#
require 'rails_helper'

RSpec.describe Release, type: :model do
  describe 'associations' do
    it { should belong_to(:application) }
    it { should have_many(:commit_releases).dependent(:destroy) }
    it { should have_many(:commits).through(:commit_releases) }
  end

  describe 'validations' do
    it { should validate_presence_of(:version) }
    it { should validate_inclusion_of(:deploy_status).in_array(['success', 'failure', nil]) }
  end
end
