release: rails db:migrate && rails data:migrate
sidekiq: bundle exec sidekiq
web: bin/rails server -p $PORT -e $RAILS_ENV