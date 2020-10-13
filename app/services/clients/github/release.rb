# frozen_string_literal: true

module Clients
  module Github
    class Release < GithubBase
      def list(repository)
        @client.list_releases(repository, {
                                per_page: 100
                              })
      end

      def create(repository, tag_name, target, body, prerelease)
        @client.create_release(repository, tag_name, {
                                 target_commitish: target,
                                 body: body,
                                 prerelease: prerelease
                               })
      end

      # @TODO: review this method, it does not seem to work
      def delete(url)
        @client.delete_release(url)
      end
    end
  end
end
