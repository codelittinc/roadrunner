class ChannelsController < ApplicationController
  def index
    @channels = Clients::Notifications::Channel.new(Customer.find(1)).list

    respond_to do |format|
      format.json { render partial: "index", locals: { channels: @channels } } # index.json.erb
    end
  end
end
