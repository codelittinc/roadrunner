FactoryBot.define do
  factory :check_run do
    state { 'success' }
    commit_sha { '1' }
  end
end
