# frozen_string_literal: true

DEFAULT_NO_DEVOPS_CODE = 'Not assigned'

namespace :sprints do
  desc 'update the state of the sprints in jira'
  task update_sprints_state_jira: :environment do
    Tasks::JiraSprintsUpdate.new.update!
  end
end
