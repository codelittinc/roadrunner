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
FactoryBot.define do
  factory :release do
    version { "v#{rand(100)}.#{rand(100)}.#{rand(100)}" }
  end
end
