# frozen_string_literal: true

class UpdateBranchsToCheckRuns < ActiveRecord::Migration[6.1]
  def up
    CheckRun.find_each do |f|
      flow = FlowRequest.where("json like ? AND flow_name = 'Flows::CheckRunFlow'", "%\"sha\":\"#{f.commit_sha}\"%").first
      flow_json = JSON.parse(flow.json)
      repository = Repository.where(name: flow_json['repository']['name']).first_or_create
      branch = Branch.where(name: flow_json['branches'][0]['name'], repository: repository).first_or_create
      f.update(branch: branch)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
