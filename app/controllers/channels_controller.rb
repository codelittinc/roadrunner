# frozen_string_literal: true

class ChannelsController < ApplicationController
  def index
    customer = Repository.default_project.customer
    @channels = Clients::Notifications::Channel.new(customer).list

    respond_to do |format|
      format.json { render :index, formats: :json } # index.json.erb
    end
  end
end
