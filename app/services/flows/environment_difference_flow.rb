# frozen_string_literal: true

module Flows
  class EnvironmentDifferenceFlow < BaseFlow
    def execute; end

    def can_execute?
      text.present? &&
        text.split.size == 5 &&
        text.include?('env diff') &&
        repository.present? &&
        head_env.present? &&
        base_env.present?
    end

    private

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
