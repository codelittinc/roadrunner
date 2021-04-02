# frozen_string_literal: true

# == Schema Information
#
# Table name: user_admins
#
#  id              :bigint           not null, primary key
#  username        :string
#  email           :string
#  password_digest :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
require 'rails_helper'

RSpec.describe UserAdmin, type: :model do
  describe 'should validate the props' do
    it { is_expected.to validate_presence_of(:username) }
    it { is_expected.to validate_presence_of(:email) }
  end
end
