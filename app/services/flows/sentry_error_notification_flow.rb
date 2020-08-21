module Flows
  class SentryErrorNotificationFlow < BaseFlow
    def execute
      ServerIncidentService.new.register_incident!(server, title)
    end

    def can_execute?
      server && @params[:project_slug]
    end

    private

    def project_name
      @project_name ||= @parser.project_name
    end

    def title
      @title ||= @parser.title
    end

    def server
      @server ||= Server.find_by(external_identifier: project_name)
    end
  end
end
