class SourceControl < ApplicationRecord
  belongs_to :pull_request
  belongs_to :source, polymorphic: true
end
