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
FactoryBot.define do
  factory :commit do
    sha { 'MyString' }
    message { 'MyString' }
    author_name { 'MyString' }
    author_email { 'MyString' }
  end
end
