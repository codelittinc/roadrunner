# frozen_string_literal: true

class PingAfiniumServersWorker
  include Sidekiq::Worker

  def perform(*_args)
    Tasks::AfiniumServersTask.check_afinium_servers!
  end
end
