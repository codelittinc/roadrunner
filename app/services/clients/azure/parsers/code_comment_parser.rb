# frozen_string_literal: true

module Clients
  module Azure
    module Parsers
      class CodeCommentParser < ClientParser
        attr_reader :pull_request_source_control_id, :comment, :author


        def parse!
          return unless valid_comment?
          pull_request_url = @json["_links"]["pullRequests"]["href"]
          @pull_request_source_control_id = pull_request_url.split('/').last
          @comment = @json["content"]
          author_email = @json["author"]["uniqueName"]
          @author = Clients::Backstage::User.new.list(author_email)&.first&.id
        end

        private

        def valid_comment?
          author_name = @json["author"]["displayName"]

          !author_name.starts_with?("Microsoft")
        end
      end
    end
  end
end
