class User < ApplicationRecord
  validates :slack, presence: true

  include PgSearch
  pg_search_scope :search_by_term, against: [:jira, :slack, :github]
end
