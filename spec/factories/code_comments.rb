# frozen_string_literal: true

# == Schema Information
#
# Table name: code_comments
#
#  id              :bigint           not null, primary key
#  comment         :string
#  published_at    :date
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  author_id       :integer
#  pull_request_id :bigint           not null
#
# Indexes
#
#  index_code_comments_on_pull_request_id  (pull_request_id)
#
# Foreign Keys
#
#  fk_rails_...  (pull_request_id => pull_requests.id)
#
FactoryBot.define do
  factory :code_comment do
    author_id { 1 }
    pull_request { nil }
    comment { 'MyString' }
  end
end
