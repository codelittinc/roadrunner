# == Schema Information
#
# Table name: commits
#
#  id              :bigint           not null, primary key
#  author_email    :string
#  author_name     :string
#  message         :string
#  sha             :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  pull_request_id :bigint
#
# Indexes
#
#  index_commits_on_pull_request_id  (pull_request_id)
#
FactoryBot.define do
  factory :commit do
    sha { 'MyString' }
    message { 'MyString' }
    author_name { 'MyString' }
    author_email { 'MyString' }
  end
end
