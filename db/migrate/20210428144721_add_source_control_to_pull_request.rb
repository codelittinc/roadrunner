class AddSourceControlToPullRequest < ActiveRecord::Migration[6.1]
  def change
    add_reference :pull_requests, :source_control, polymorphic: true, null: false
  end
end
