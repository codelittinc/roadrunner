class User < ApplicationRecord
  include PgSearch
  pg_search_scope :search_by_term, against: [:jira, :slack, :github]

  has_many :pull_requests
end
