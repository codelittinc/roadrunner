# frozen_string_literal: true

require 'ostruct'

module Flows
  module Repositories
    module PullRequest
      module Close
        class AzureParser < Parsers::BaseAzureParser
          delegate :missing, to: :azure_create_parser, allow_nil: false 

          def azure_create_parser
            Flows::Repositories::PullRequest::Create::AzureParser.new(json: @json)
          end

          def close_pull_request_flow?
            (event_type == 'git.pullrequest.merged' || event_type == 'git.pullrequest.updated') && (@status == 'completed' || @status == 'abandoned')
          end
        end
      end
    end
  end
end
