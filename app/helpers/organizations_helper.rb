# frozen_string_literal: true

module OrganizationsHelper
  def slack_url
    response = Request.get("https://api.notifications.codelitt.dev")
    response["slack_url"]
  end
end
