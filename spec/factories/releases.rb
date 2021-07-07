# frozen_string_literal: true

# == Schema Information
#
# Table name: releases
#
#  id             :bigint           not null, primary key
#  version        :string
#  application_id :bigint
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  deploy_status  :string
#
FactoryBot.define do
  factory :release do
    version { "v#{rand(100)}.#{rand(100)}.#{rand(100)}" }
  end
end
