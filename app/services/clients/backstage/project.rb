# frozen_string_literal: true

class CustomerMimic
  attr_reader :name, :slack_api_key, :github_api_key

  def initialize(customer_parms)
    @name = customer_parms['name']
    @slack_api_key = customer_parms['notifications_token']
    @github_api_key = customer_parms['source_control_token']
  end
end

class ProjectMimic
  attr_reader :id, :name, :customer, :metadata

  def initialize(project_params, customer)
    @id = project_params['id']
    @name = project_params['name']
    @customer = customer
    @metadata = project_params['metadata']
  end
end

module Clients
  module Backstage
    class Project < Client
      def show(id)
        return nil unless id

        response = Request.get("#{@url}/projects/#{id}", authorization)

        customer = CustomerMimic.new(response['customer'])
        ProjectMimic.new(response, customer)
      end
    end
  end
end
