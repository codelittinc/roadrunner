FactoryBot.define do
  factory :commit do
    sha { 'MyString' }
    message { 'MyString' }
    author_name { 'MyString' }
    author_email { 'MyString' }
  end
end
