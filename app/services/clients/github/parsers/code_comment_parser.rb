# frozen_string_literal: true

module Clients
  module Github
    module Parsers
      class CodeCommentParser < ClientParser
        attr_reader :pull_request_source_control_id, :comment, :author

        def parse!
          @pull_request_source_control_id = @json[:pull_request_url].split('/').last
          @comment = @json[:body]
          @author = Clients::Backstage::User.new.list(@json[:user][:login])&.first&.id
        end
      end
    end
  end
end
