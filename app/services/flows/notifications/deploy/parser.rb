# frozen_string_literal: true

module Flows
  module Notifications
    module Deploy
      class Parser < Parsers::BaseParser
        attr_reader :environment,
                    :source,
                    :status,
                    :deploy_type,
                    :message

        def can_parse?
          @json[:deploy_type] == 'deploy-notification'
        end

        def parse!
          @environment = @json[:env].upcase
          @source = @json[:host]
          @status = @json[:status] || 'success'
          @deploy_type = @json[:type]&.upcase
          @message = @json[:message]
        end
      end
    end
  end
end
