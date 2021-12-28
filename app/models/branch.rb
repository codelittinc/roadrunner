# frozen_string_literal: true

# == Schema Information
#
# Table name: branches
#
#  id              :bigint           not null, primary key
#  name            :string
#  repository_id   :bigint           not null
#  pull_request_id :bigint
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class Branch < ApplicationRecord
  belongs_to :repository
  belongs_to :pull_request, optional: true

  has_many :check_runs, dependent: :destroy

  validates :name, presence: true
  validates :pull_request, uniqueness: true, allow_nil: true
end
