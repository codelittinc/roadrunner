# frozen_string_literal: true

DEFAULT_NO_DEVOPS_CODE = 'Not assigned'

namespace :sprints do
  desc 'update the state of the sprints in azure'
  task update_sprints_state_azure: :environment do
    Tasks::AzureSprintsUpdate.new.update!
  end
end
