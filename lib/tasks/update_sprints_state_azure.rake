# frozen_string_literal: true

namespace :sprints do
  desc 'update the state of the sprints in azure'
  task update_sprints_state_azure: :environment do
    # clean current data
    Issue.delete_all
    Sprint.delete_all

    # pull latest data
    teams = ['Visualization', 'Appraisal', 'Data Team', 'Mobile Team', 'Properties']

    sprints_per_team = teams.map { |team| [team, Clients::Azure::Sprint.new.list(team)] }

    sprints_per_team.map do |team, sprints|
      sprints.map do |sprint|
        sprint_obj = Sprint.new(
          start_date: Date.parse(sprint.start_date),
          end_date: Date.parse(sprint.end_date),
          name: sprint.name,
          time_frame: sprint.time_frame, team: team
        )
        sprint_obj.save!
        Clients::Azure::Sprint.new.work_items(team, sprint.id).each do |issue|
          user = User.search_by_term(issue.assigned_to).first

          next unless user

          Issue.new(
            story_type: issue.story_type,
            state: issue.state,
            title: issue.title,
            user: user,
            sprint: sprint_obj,
            story_points: issue.story_points
          ).save!
        end
      end
    end
  end
end
