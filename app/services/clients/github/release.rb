# frozen_string_literal: true

module Clients
  module Github
    class Release < GithubBase
      def list(repository)
        releases = @client.list_releases(repository, {
                                           per_page: 100
                                         })
        releases.map do |release|
          Clients::Github::Parsers::ReleaseParser.new(release)
        end
      end

      def create(repository, tag_name, target, body, prerelease)
        release = @client.create_release(repository, tag_name, {
                                           target_commitish: target,
                                           body: body,
                                           prerelease: prerelease
                                         })
        Clients::Github::Parsers::ReleaseParser.new(release)
      end

      # @TODO: review this method, it does not seem to work
      def delete(url)
        @client.delete_release(url)
      end
    end
  end
end
