# frozen_string_literal: true

module Flows
  class SentryIncidentNotificationFlow < BaseFlow
    delegate :project_name, :issue_id, :event_id, :type, :custom_message, :custom_name, to: :parser

    def execute
      notify_sentry_error_message = Messages::GenericBuilder.notify_sentry_error(title, metadata, user, browser_name, link_sentry, type, custom_message)
      ApplicationIncidentService.new.register_incident!(application, notify_sentry_error_message, nil, ApplicationIncidentService::SENTRY_MESSAGE_TYPE)
    end

    def can_execute?
      application && @params[:project_slug]
    end

    private

    def title
      @title ||= @parser.event_title
    end

    def metadata
      @metadata ||= @parser.event_metadata
    end

    def browser_name
      @browser_name ||= @parser.event_contexts.dig(:browser, :name)
    end

    def user
      @user ||= @parser.event_user
    end

    def link_sentry
      return azure_link if repository_source == 'azure'

      github_link
    end

    def project_id
      @project_id ||= @parser.event_project
    end

    def application
      @application ||= Application.by_external_identifier([custom_name, project_name])
    end

    def repository
      @repository ||= application.repository
    end

    def customer
      repository.project.customer
    end

    def repository_source
      @repository_source ||= repository.source_control_type
    end

    def azure_link
      # TODO: Build link without hard code for the organization, using project_name property instead avison-young
      "https://sentry.io/organizations/avison-young/issues/#{issue_id}/events/#{event_id}/?project=#{project_id}"
    end

    def github_link
      "https://sentry.io/organizations/#{customer.sentry_name}/issues/#{issue_id}/events/#{event_id}/?project=#{project_id}"
    end
  end
end
