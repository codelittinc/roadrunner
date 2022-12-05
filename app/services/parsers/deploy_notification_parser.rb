# frozen_string_literal: true

module Parsers
  class DeployNotificationParser < BaseParser
    delegate_missing_to :data

    DEFAULT_STATUS = 'success'
    EXPECTED_DEPLOY_TYPE = 'deploy-notification'

    def can_parse?
      @json[:deploy_type] == EXPECTED_DEPLOY_TYPE
    end

    def parse!
      @data = OpenStruct.new(
        environment: @json[:env].upcase,
        source: @json[:host],
        status: @json[:status] || DEFAULT_STATUS,
        deploy_type: @json[:type]&.upcase
      )
    end
  end
end
