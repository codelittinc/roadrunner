# frozen_string_literal: true

# == Schema Information
#
# Table name: github_installations
#
#  id              :bigint           not null, primary key
#  installation_id :string
#  organization_id :bigint
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  name            :string
#
FactoryBot.define do
  factory :github_installation do
    organization { association :organization }
    installation_id { '30421922' }
  end
end
