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
        response = Request.get("#{@url}/users?query=#{query_string}", authorization)
        response.map { |user| BackstageUser.new(user) }
      end
    end
  end
end
