namespace :server do
  desc 'checks if the servers are up'
  task check_up_servers: :environment do
    Tasks::ServerTask.check_up_servers!
  end
end
