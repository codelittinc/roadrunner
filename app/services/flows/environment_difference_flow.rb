# frozen_string_literal: true

module Flows
  class EnvironmentDifferenceFlow < BaseFlow
    def execute
      differences = head_env.releases.last.commits.where("NOT EXISTS (
        SELECT 1 FROM commit_releases
        WHERE commit_releases.commit_id = commits.id
        AND commit_releases.release_id IN (?)
      )", [base_env.releases.last])

      changelog = differences.map do |difference|
        " - #{difference.message}"
      end.join("\n")

      message = "The differente between #{base_env.environment} and #{head_env.environment} is:\n#{changelog}".strip

      Clients::Notifications::Direct.new.send(message, user_name)
    end

    def can_execute?
      text.present? &&
        text.split.size == 5 &&
        text.include?('env diff') &&
        repository.present? &&
        head_env.present? &&
        base_env.present?
    end

    private

    def user_name
      @user_name ||= @params[:user_name]
    end

    def text
      @text ||= @params[:text]
    end

    def repository
      repository_name = text.split.third
      Repository.find_by(name: repository_name)
    end

    def base_env
      base_env_name = text.split.fourth
      repository.applications.find_by(environment: base_env_name)
    end

    def head_env
      head_env_name = text.split.last
      repository.applications.find_by(environment: head_env_name)
    end
  end
end
