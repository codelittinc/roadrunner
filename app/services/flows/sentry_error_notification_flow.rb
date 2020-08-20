module Flows
  class SentryErrorNotificationFlow < BaseFlow
    def execute
      ServerIncidentService.new.register_incident!(server, message)
    end

    def can_execute?
      server && message && @params[:project_slug]
    end

    private

    def project_name
      @project_name ||= @parser.project_name
    end

    def message
      @message ||= @parser.message
    end

    def server
      @server ||= Server.find_by(alias: project_name)
    end
  end
end
