# frozen_string_literal: true

module Clients
  module Github
    module Parsers
      class CodeCommentParser < ClientParser
        attr_reader :pull_request_source_control_id, :comment, :author, :published_at

        def initialize(json, pull_request)
          @pull_request = pull_request
          super(json)
        end

        def parse!
          @pull_request_source_control_id = @json[:pull_request_url].split('/').last
          @author = Clients::Backstage::User.new.list(@json[:user][:login])&.first&.id
          @comment = @json[:body] if valid_author?
          @published_at = @json[:created_at]
        end

        private

        def valid_author?
          @pull_request.backstage_user_id != author
        end
      end
    end
  end
end
