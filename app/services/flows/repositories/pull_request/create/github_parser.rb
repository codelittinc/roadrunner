# frozen_string_literal: true

require 'ostruct'

module Flows
  module Repositories
    module PullRequest
      module Create
        class GithubParser < Parsers::BaseParser
          attr_reader :base, :branch_name, :description, :draft, :source_control_id, :head, :merged, :owner,
                      :repository_name, :state, :title, :username, :action, :commit_sha, :conclusion

          def source_control_pull_request
            Clients::Github::PullRequest
          end

          def can_parse?
            @json && !!pull_request && @json[:action] != 'synchronize'
          end

          def new_pull_request_flow?
            action == 'opened' || action == 'ready_for_review'
          end

          def parse!
            parse_pull_request! if pull_request
            @owner = @json.dig(:organization, :login) || @json.dig(:pull_request, :head, :repo, :owner, :login)
            @repository_name = @json.dig(:repository, :name)
            @username = @json.dig(:sender, :login).downcase
            @action = @json[:action]
          end

          def user_by_source_control
            User.find_or_initialize_by(github: username)
          end

          def build_source(pull_request)
            GithubPullRequest.new(source_control_id:, pull_request:)
          end

          private

          def parse_pull_request!
            @base = pull_request&.dig(:base, :ref)
            @description = pull_request&.dig(:body)
            @draft = pull_request&.dig(:draft)
            @source_control_id = pull_request&.dig(:number)
            @head = pull_request&.dig(:head, :ref)
            @merged = pull_request[:merged]
            @state = pull_request&.dig(:state)
            @title = pull_request&.dig(:title)
          end

          def pull_request
            @json[:pull_request]
          end
        end
      end
    end
  end
end
