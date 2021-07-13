# frozen_string_literal: true

require 'nested_form/engine'
require 'nested_form/builder_mixin'

# rubocop:disable Metrics/BlockLength
RailsAdmin.config do |config|
  ### Popular gems integration

  if ENV['ENABLE_AUTH'] == 'true'
    config.authenticate_with do
      authenticate_or_request_with_http_basic('Login required') do |username, password|
        user = UserAdmin.where(username: username).or(UserAdmin.where(email: username)).first
        user&.authenticate(password) if user
      end
    end
  end

  RailsAdmin.config User do
    list do
      include_fields :github, :azure_devops_issues, :slack, :azure, :jira, :id
    end
  end

  RailsAdmin.config FlowRequest do
    list do
      include_fields :json, :executed, :flow_name, :error_message, :created_at
    end
  end

  ## == CancanCan ==
  # config.authorize_with :cancancan

  ## == Pundit ==
  # config.authorize_with :pundit

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  config.main_app_name = %w[Roadrunner Admin]
  ## == Gravatar integration ==
  ## To disable Gravatar integration in Navigation Bar set to false
  # config.show_gravatar = true

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end
end
# rubocop:enable Metrics/BlockLength
