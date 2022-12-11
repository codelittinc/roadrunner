# frozen_string_literal: true

module OrganizationsHelper
  def github_url(organization)
    "https://github.com/apps/roadrunner-codelitt/installations/new?state=#{organization.id}"
  end

  def slack_url
    response = SimpleRequest.get(ENV.fetch('NOTIFICATIONS_API_URL'))
    response['slack_url']
  end
end
