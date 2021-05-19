# frozen_string_literal: true

require 'net/http'

module Clients
  module Azure
    class Release < AzureBase
      def list(repository)
        url = "#{azure_url}git/repositories/#{repository.name}/refs?api-version=6.1-preview.1&filterContains=tag"
        response = Request.get(url, authorization)
        releases = response['value']
        parsed_releases = releases.map do |release|
          Clients::Azure::Parsers::ReleaseParser.new(release)
        end

        sort_releases(parsed_releases).reverse
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
        last_commit = Branch.new.commits(repository, target).first
        {
          name: tag_name,
          taggedObject: {
            objectId: last_commit.sha
          },
          message: last_commit.message
        }
      end

      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/PerceivedComplexity
      def sort_releases(releases)
        releases.sort do |a, b|
          is_a_pre_release = a.tag_name.match?(/^rc/)
          is_b_pre_release = b.tag_name.match?(/^rc/)

          is_a_major_release = a.tag_name.match?(/^v/)
          is_b_major_release = b.tag_name.match?(/^v/)

          a_stable_version = a.tag_name.scan(/\d+.\d+.\d+$/).first
          b_stable_version = b.tag_name.scan(/\d+.\d+.\d+$/).first

          a_pre_release_version = a.tag_name.scan(/^rc.(\d+)/).first
          b_pre_release_version = b.tag_name.scan(/^rc.(\d+)/).first

          result = nil
          if is_a_pre_release && is_b_pre_release
            result = if a_stable_version == b_stable_version
                       a_pre_release_version <=> b_pre_release_version
                     else
                       a_stable_version <=> b_stable_version
                     end
          elsif is_a_major_release && is_b_major_release
            result = a_stable_version <=> b_stable_version
          elsif is_a_pre_release && is_b_major_release || is_a_major_release && is_b_pre_release
            if a_stable_version == b_stable_version
              -1
            else
              result = a_stable_version <=> b_stable_version
            end
          end

          result || a.tag_name <=> b.tag_name
        end
      end
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/PerceivedComplexity
    end
  end
end
