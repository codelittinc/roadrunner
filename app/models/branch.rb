# frozen_string_literal: true

# == Schema Information
#
# Table name: branches
#
#  id              :bigint           not null, primary key
#  name            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  pull_request_id :bigint
#  repository_id   :bigint           not null
#
# Indexes
#
#  index_branches_on_pull_request_id  (pull_request_id) UNIQUE
#  index_branches_on_repository_id    (repository_id)
#
# Foreign Keys
#
#  fk_rails_...  (pull_request_id => pull_requests.id)
#  fk_rails_...  (repository_id => repositories.id)
#
class Branch < ApplicationRecord
  belongs_to :repository
  belongs_to :pull_request, optional: true

  has_many :check_runs, dependent: :destroy

  validates :name, presence: true
  validates :pull_request, uniqueness: true, allow_nil: true
end
