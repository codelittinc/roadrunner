# frozen_string_literal: true

module Tasks
  class AzureSprintsUpdate < SprintsBase
    TEAMS = ['Visualization', 'Appraisal', 'Data Team', 'Mobile Team', 'Properties', 'Skyline'].freeze

    def source
      'azure'
    end

    def update_info!
      sprints_per_team.map do |team, sprints|
        sprints.map do |sprint|
          sprint_obj = create_sprint!(sprint, team)

          Clients::Azure::Sprint.new.work_items(team, sprint.id).each do |issue|
            assigned_to = issue.assigned_to || DEFAULT_NO_DEVOPS_CODE
            user = find_user(assigned_to, issue.display_name)

            create_issue!(issue, sprint_obj, user)
          end
        end
      end
    end

    def sprints_per_team
      @sprints_per_team ||= TEAMS.map { |team| [team, Clients::Azure::Sprint.new.list(team)] }
    end

    def initialize_user(name, assigned_to)
      User.new(azure_devops_issues: assigned_to, name:, customer:)
    end

    def create_sprint!(sprint, team)
      Sprint.create(
        start_date: Date.parse(sprint.start_date),
        end_date: Date.parse(sprint.end_date),
        name: sprint.name, time_frame: sprint.time_frame,
        team:, customer:
      )
    end

    def create_issue!(data, sprint, user)
      Issue.create(
        story_type: data.story_type,
        state: data.state,
        title: data.title,
        user:,
        sprint:,
        story_points: data.story_points,
        tags: data.tags
      )
    end
  end
end
