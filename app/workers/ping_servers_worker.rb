# frozen_string_literal: true

class PingServersWorker
  include Sidekiq::Worker

  def perform(*_args)
    Tasks::ServerTask.check_up_servers!
  end
end
