# frozen_string_literal: true

# == Schema Information
#
# Table name: applications
#
#  id                  :bigint           not null, primary key
#  environment         :string
#  version             :string
#  external_identifier :string
#  repository_id       :bigint           not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
require 'rails_helper'

RSpec.describe Application, type: :model do
  describe 'associations' do
    it { should belong_to(:repository) }
    it { should have_one(:server).dependent(:destroy) }
    it { should have_many(:server_incidents) }
  end

  describe 'validations' do
    it { should validate_presence_of(:environment) }
    it { should validate_presence_of(:version) }
    it { should validate_presence_of(:external_identifier) }

    it 'should be unique' do
      FactoryBot.create(:application)
      should validate_uniqueness_of(:external_identifier)
    end

    describe 'accepts only valid values in the environment' do
      let(:app) do
        FactoryBot.build(:application)
      end

      it 'dev' do
        expect(app).to validate_inclusion_of(:environment).in_array(%w[dev qa prod])
      end
    end
  end
end
