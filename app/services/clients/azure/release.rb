# frozen_string_literal: true

require 'net/http'

module Clients
  module Azure
    class Release < AzureBase
      def list
        url = "#{azure_api_url}/release/releases?api-version=4.1-preview.6"
        response = Request.get(url, authorization)
        response['value']
      end

      def create(repository, tag_name, target, _body, _prerelease)
        url = "#{azure_url}git/repositories/#{repository}/annotatedtags"
        uri = URI.parse(url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true

        request = Net::HTTP::Post.new(uri.path, { 'Content-Type' => 'application/json' })
        request.body = build_body_release(repository, tag_name, target).to_json
        request['Authorization'] = authorization
        request['Accept'] = 'application/json; api-version=4.1-preview.1'

        http.request(request)
      end

      private

      def build_body_release(repository, tag_name, target)
        last_commit = Branch.new.commits(repository, target).last
        {
          name: tag_name,
          taggedObject: {
            objectId: last_commit['commitId']
          },
          message: last_commit['comment']
        }
      end
    end
  end
end