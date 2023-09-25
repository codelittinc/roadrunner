# frozen_string_literal: true

class ChannelsController < ApplicationController
  def index
    @channels = Clients::Notifications::Channel.new(Customer.find(1)).list

    respond_to do |format|
      format.json { render :index, formats: :json } # index.json.erb
    end
  end
end
