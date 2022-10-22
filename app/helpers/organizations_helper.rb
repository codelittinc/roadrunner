# frozen_string_literal: true

module OrganizationsHelper
  def github_url(organization)
    "https://github.com/apps/roadrunner-codelitt/installations/new?state=#{organization.id}"
  end

  def slack_url
    response = Request.get('https://api.notifications.codelitt.dev')
    response['slack_url']
  end
end
