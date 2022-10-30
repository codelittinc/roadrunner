# frozen_string_literal: true

class InstallationRepositoriesCreator < ApplicationService
  def initialize(installation_id)
    super()
    @installation_id = installation_id
  end

  def call
    installation = GithubInstallation.find(@installation_id)
    repositories = Clients::ApplicationGithub::Repository.new(installation.installation_id).list
    repositories.each do |repository|
      rep = Repository.find_or_initialize_by(name: repository.name, owner: repository.owner)
      next if rep.persisted?

      rep.source_control_type = 'github'
      # @TODO: remove friendly name
      rep.friendly_name = (0...10).map { ('a'..'z').to_a[rand(26)] }.join
      rep.save!
    end
  end
end
