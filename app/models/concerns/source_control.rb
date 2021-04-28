module SourceControl
  extend ActiveSupport::Concern

  included do
    has_many :pull_requests, :as => :source_control
  end
end