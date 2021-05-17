# frozen_string_literal: true

require 'net/http'

module Clients
  module Azure
    class Release < AzureBase
      def list(repository)
        url = "#{azure_url}git/repositories/#{repository.name}/refs?api-version=6.1-preview.1&filterContains=tag"
        response = Request.get(url, authorization)
        releases = response['value']
        releases.map do |release|
          Clients::Azure::Parsers::ReleaseParser.new(release)
        end
      end

      def create(repository, tag_name, target, _body, _prerelease)
        url = "#{azure_url}git/repositories/#{repository.name}/annotatedtags"
        uri = URI.parse(url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true

        request = Net::HTTP::Post.new(uri.path, { 'Content-Type' => 'application/json' })
        request.body = build_body_release(repository, tag_name, target).to_json
        request['Authorization'] = authorization
        request['Accept'] = 'application/json; api-version=6.1-preview.1'

        release = JSON.parse(http.request(request).body)
        Clients::Azure::Parsers::ReleaseParser.new(release)
      end

      private

      def build_body_release(repository, tag_name, target)
        last_commit = Branch.new.commits(repository, target).last
        {
          name: tag_name,
          taggedObject: {
            objectId: last_commit.sha
          },
          message: last_commit.message
        }
      end
    end
  end
end
