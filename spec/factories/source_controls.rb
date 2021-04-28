FactoryBot.define do
  factory :source_control do
    content { "MyString" }
    pull_request_id { 1 }
    source_control_id { 1 }
    source_control_type { "MyString" }
  end
end
