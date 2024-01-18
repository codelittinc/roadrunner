# == Schema Information
#
# Table name: code_comments
#
#  id              :bigint           not null, primary key
#  comment         :string
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
require 'rails_helper'

RSpec.describe CodeComment, type: :model do
  describe 'should validate the props' do
    it { is_expected.to validate_presence_of(:comment) }
    it { is_expected.to validate_presence_of(:author_id) }
  end

  describe 'associations' do
    it { should belong_to(:pull_request) }
  end
end
