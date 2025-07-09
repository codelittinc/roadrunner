# frozen_string_literal: true

class BackstageUser
  attr_reader :email, :id, :slack

  def initialize(params)
    @params = params
    @email = params['email']
    @id = params['id']
    @slack = identifier('slack')
  end

  def identifier(service_name)
    @params['user_service_identifiers']&.find { |service| service['service_name'] == service_name }&.dig('identifier')
  end
end

module Clients
  module Backstage
    class User < Client
      def list(*query)
        query_string = query.join(',')
        response = get_users(query_string)
        response.map { |user| BackstageUser.new(user) }
      end

      def get_users(query_string)
        uri = URI.parse(build_url("/users?query=#{query_string}"))
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        req = Net::HTTP::Get.new(uri.request_uri, { 'Project-Auth-Key' => authorization })
        JSON.parse(http.request(req).body)
      end
    end
  end
end
