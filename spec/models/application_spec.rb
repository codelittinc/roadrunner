# frozen_string_literal: true

# == Schema Information
#
# Table name: applications
#
#  id            :bigint           not null, primary key
#  environment   :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  repository_id :bigint           not null
#
# Indexes
#
#  index_applications_on_repository_id  (repository_id)
#
# Foreign Keys
#
#  fk_rails_...  (repository_id => repositories.id)
#
require 'rails_helper'

RSpec.describe Application, type: :model do
  describe 'associations' do
    it { should belong_to(:repository) }
    it { should have_one(:server).dependent(:destroy) }
    it { should have_many(:server_incidents) }
    it { should have_many(:releases) }
    it { should have_many(:external_identifiers).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:environment) }

    it 'only accepts valid values in the environment' do
      app = FactoryBot.build(:application)
      expect(app).to validate_inclusion_of(:environment).in_array(%w[dev qa uat prod])
    end
  end

  describe '#latest_release' do
    context 'when there are multiple releases' do
      it 'returns the newest one' do
        application = FactoryBot.create(:application)
        FactoryBot.create(:release, application:)
        FactoryBot.create(:release, application:)
        latest_release = FactoryBot.create(:release, application:)

        expect(application.latest_release).to eq(latest_release)
      end
    end
  end
end
