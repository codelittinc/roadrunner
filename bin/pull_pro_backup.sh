docker-compose -f docker-compose.development.yml up -d
docker stop roadrunner-project-api
heroku pg:backups:capture --app prod-roadrunner
heroku pg:backups:download --app prod-roadrunner
docker exec -it roadrunner-project-db psql -U postgres -c 'DROP DATABASE IF EXISTS roadrunner_development'
docker exec -it roadrunner-project-db psql -U postgres -c "CREATE DATABASE roadrunner_development"
docker exec -it roadrunner-project-db pg_restore --no-owner  -U postgres -d roadrunner_development -1 ./share/latest.dump
sh bin/dev
