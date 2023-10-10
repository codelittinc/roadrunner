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
  attr_reader :id, :name, :customer

  def initialize(project_params, customer)
    @id = project_params['id']
    @name = project_params['name']
    @customer = customer
  end
end

module Clients
  module Backstage
    class Project < Client
      def show(id)
        reponse = Request.get("#{@url}/projects/#{id}", authorization)
        customer = CustomerMimic.new(reponse['customer'])
        ProjectMimic.new(reponse, customer)
      end
    end
  end
end
