# frozen_string_literal: true

module Flows
  module Notifications
    module IosReleases
      class Parser < Parsers::BaseParser
        attr_reader :name, :use_mock, :slack_channel

        def can_parse?
          @json[:name] == 'check-ios-releases'
        end

        def parse!
          @name = @json[:name].downcase
          @use_mock = @json[:use_mock] || false
          @slack_channel = @json[:slack_channel] || '#team-roadrunner'
        end
      end
    end
  end
end
