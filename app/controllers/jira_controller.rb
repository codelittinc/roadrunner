class JiraController < ApplicationController
  def index
    projects = Clients::Jira::Project.new.list
    issues = Clients::Jira::Issue.new.list('AYPI', 'In Progress')
    statuses = Clients::Jira::Status.new.list('AYPI')
    status = Clients::Jira::Status.new.list('AYPI', 'In Review')

    render json: {
      projects: projects,
      issues: issues,
      statuses: statuses,
      status: status
    }, status: :ok
  end
end
