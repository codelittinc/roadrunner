# frozen_string_literal: true

class RepositoriesController < ApplicationController
  before_action :set_repository, only: %i[show update destroy]

  def index
    query = params[:query]
    @repositories = Repository.ransack(owner_cont: query, name_cont: query, m: 'or').result
    respond_to do |format|
      format.json { render :index, formats: :json } # index.json.erb
    end
  end

  def show
    respond_to do |format|
      format.json { render :show, formats: :json }
    end
  end

  def create
    @repository = CreateRepositoryService.call(repository_params)

    respond_to do |format|
      if @repository.errors.empty?
        format.json { render :show, status: :created, location: @repository }
      else
        format.json { render json: @repository.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @repository.update(repository_params)
        format.json { render :show, status: :ok, location: @repository }
      else
        format.json { render json: @repository.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /repositories/1 or /repositories/1.json
  def destroy
    @repository.destroy

    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private

  def set_repository
    @repository = Repository.friendly.find(params[:id])
  end

  def repository_params
    params.require(:repository).permit!
  end
end
