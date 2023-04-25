rm latest.dump
docker-compose up -d
docker stop roadrunner-api
docker stop roadrunner-sidekiq
heroku pg:backups:capture --app prod-roadrunner
heroku pg:backups:download --app prod-roadrunner
docker exec -it roadrunner-db psql -U postgres -c 'DROP DATABASE IF EXISTS roadrunner_development'
docker exec -it roadrunner-db psql -U postgres -c "CREATE DATABASE roadrunner_development"
docker exec -it roadrunner-db psql -U postgres roadrunner_development -c "CREATE SCHEMA IF NOT EXISTS heroku_ext AUTHORIZATION postgres"
docker exec -it roadrunner-db pg_restore --no-owner  -U postgres -d roadrunner_development -1 ./app/latest.dump
sh bin/dev
