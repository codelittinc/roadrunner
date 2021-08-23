# frozen_string_literal: true

# == Schema Information
#
# Table name: commits
#
#  id              :bigint           not null, primary key
#  sha             :string
#  message         :string
#  author_name     :string
#  author_email    :string
#  pull_request_id :bigint
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class Commit < ApplicationRecord
  belongs_to :pull_request
  has_many :commit_releases, dependent: :destroy
  has_many :releases, through: :commit_releases

  validates :sha, presence: true
  validates :author_name, presence: true
end
