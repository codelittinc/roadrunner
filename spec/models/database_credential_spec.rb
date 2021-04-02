# frozen_string_literal: true

# == Schema Information
#
# Table name: database_credentials
#
#  id            :bigint           not null, primary key
#  env           :string
#  database_type :string
#  name          :string
#  db_host       :string
#  db_user       :string
#  db_name       :string
#  db_password   :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
require 'rails_helper'

RSpec.describe DatabaseCredential, type: :model do
  describe 'should validate the props' do
    it { is_expected.to validate_presence_of(:env) }
    it { is_expected.to validate_presence_of(:database_type) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:db_host) }
    it { is_expected.to validate_presence_of(:db_user) }
    it { is_expected.to validate_presence_of(:db_name) }
    it { is_expected.to validate_presence_of(:db_password) }
    it { should validate_inclusion_of(:env).in_array(DatabaseCredential::SUPPORTED_ENVS) }
    it { should validate_uniqueness_of(:db_host) }
    it { should validate_uniqueness_of(:name) }
  end
end
