# frozen_string_literal: true

class AddSourceControlToPullRequest < ActiveRecord::Migration[6.1]
  def change
    add_reference :pull_requests, :source, index: true, polymorphic: true
  end
end
