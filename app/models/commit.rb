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

  validates :sha, presence: true
  validates :author_name, presence: true
  validates :author_email, presence: true
end
