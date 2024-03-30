# frozen_string_literal: true

module Clients
  module Azure
    module Parsers
      class CodeCommentParser < ClientParser
        attr_reader :pull_request_source_control_id, :comment, :author, :published_at, :author_identifier

        def initialize(json, pull_request)
          @pull_request = pull_request
          super(json)
        end

        def parse!
          return unless valid_comment?

          pull_request_url = @json['_links']['pullRequests']['href']
          @pull_request_source_control_id = pull_request_url.split('/').last
          @author_identifier = @json['author']['uniqueName']
          @author = Clients::Backstage::User.new.list(@author_identifier)&.first&.id
          @comment = @json['content'] if valid_author?
          @published_at = @json['publishedDate']
        end

        private

        def valid_comment?
          author_name = @json['author']['displayName']
          comment_type = @json['commentType']

          !author_name.starts_with?('Microsoft') && comment_type == 'text'
        end

        def valid_author?
          @pull_request.backstage_user_id != author
        end
      end
    end
  end
end
