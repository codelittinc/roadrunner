# frozen_string_literal: true

class CreateRepositoryService < ApplicationService
  def initialize(params)
    super()
    @params = params
  end

  def call
    repository = Repository.new(@params)

    ActiveRecord::Base.transaction do
      repository.save
      begin
        if repository && source_control_type
          source_control_repo = Clients::SourceControlClient.new(repository).repository
        end
        Clients::SourceControlClient.new(repository).create_hook if source_control_repo
      rescue StandardError
        repository.errors.add(:base, :invalid_name,
                              message: "We couldn't find this repository name on #{source_control_type.capitalize}")
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
