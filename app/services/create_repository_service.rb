# frozen_string_literal: true

class CreateRepositoryService
  def initialize(params)
    @params = params
  end

  def self.call(*args)
    new(*args).call
  end

  def call
    repository = Repository.new(@params)

    ActiveRecord::Base.transaction do
      repository.save
      begin
        source_control_repo = Clients::SourceControlClient.new(repository).repository if repository && source_control_type
        Clients::SourceControlClient.new(repository).create_hook if source_control_repo
      rescue StandardError
        repository.errors.add(:base, :invalid_name, message: "We couldn't find this repository name on #{source_control_type.capitalize}")
        raise ActiveRecord::Rollback
      end
    end

    repository
  end

  private

  def source_control_type
    @params[:source_control_type]
  end
end
