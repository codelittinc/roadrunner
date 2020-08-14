# == Schema Information
#
# Table name: users
#
#  id         :bigint           not null, primary key
#  github     :string
#  jira       :string
#  slack      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

RSpec.describe User, type: :model do
end
