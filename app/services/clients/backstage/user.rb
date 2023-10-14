# frozen_string_literal: true

class BackstageUser
  attr_reader :email

  def initialize(params)
    @email = params['email']
  end
end

module Clients
  module Backstage
    class User < Client
      def list(query = [])
        query_string = query.join(',')
        response = Request.get("#{@url}/users?query=#{query_string}", authorization)
        response.map { |user| BackstageUser.new(user) }
      end
    end
  end
end
