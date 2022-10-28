# frozen_string_literal: true

module Tasks
  class JiraSprintsUpdate < SprintsBase
    def source
      'jira'
    end

    def customer_name
      'Codelitt'
    end

    def update_info!
      sprints_per_team.each do |team, sprints|
        sprints.each do |sprint|
          sprint_obj = create_sprint!(sprint, team)

          Clients::Jira::Issue.new.list_sprint_issues(sprint['id']).each do |issue|
            fields = issue['fields']

            assigned_to = fields.dig('assignee', 'accountId') || DEFAULT_NO_DEVOPS_CODE

            name = fields.dig('assignee', 'displayName')
            user = find_user(assigned_to, name)

            create_issue!(fields, sprint_obj, user)
          end
        end
      end
    end

    def sprints_per_team
      @sprints_per_team ||= projects.map { |team| [team, Clients::Jira::Sprint.new.list(team['id'])] }
    end

    def initialize_user(name, assigned_to)
      User.new(jira: assigned_to, name:, customer:)
    end

    def projects
      @projects ||= Clients::Jira::Board.new.list
    end

    def create_sprint!(sprint, team)
      Sprint.create(
        start_date: sprint['startDate'].nil? ? nil : Date.parse(sprint['startDate']),
        end_date: sprint['endDate'].nil? ? nil : Date.parse(sprint['endDate']),
        name: sprint['name'],
        team: team['name'],
        customer:,
        time_frame: sprint['state']
      )
    end

    def create_issue!(data, sprint, user)
      Issue.create(
        story_type: data.dig('issuetype', 'name'),
        state: data.dig('status', 'name'),
        title: data['summary'],
        user:,
        sprint:,
        story_points: data['customfield_10023']&.to_f,
        tags: data['customfield_10033']&.join(', ')
      )
    end
  end
end
