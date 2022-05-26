# frozen_string_literal: true

module Parsers
  class AppcenterDistributeNotificationParser < BaseParser
    attr_reader :platform,
                :environment,
                :source,
                :status,
                :deploy_type,
                :version,
                :install_link,
                :build

    def can_parse?
      @json && @json[:deploy_type] == 'appcenter-distribute-notification' &&
        @json[:short_version] != '' &&
        @json[:version] != ''
    end

    def parse!
      @platform = @json[:platform]
      @environment = @json[:env].upcase
      @source = @json[:host]
      @status = @json[:status] || 'success'
      @deploy_type = @json[:deploy_type]
      @version = @json[:short_version]
      @install_link = @json[:install_link]
      @build = @json[:version]
    end
  end
end
