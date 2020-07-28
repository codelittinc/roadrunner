![CI](https://github.com/codelittinc/roadrunner-rails/workflows/CI/badge.svg)

## Getting started

1. git clone git@github.com:codelittinc/roadrunner-rails.git
2.  [Install docker](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-18-04) and docker-compose
3. Add the .env content from 1Password to .env on the root folder of this project
6. Inside the project folder run `sh bin/dev`
7. Inside the docker console run:

```
bundle exec rails db:create
bundle exec rails db:migrate
SEED_CREATE_PROJECTS=true SEED_CREATE_USERS=true bundle exec rails db:seed
bundle exec rails data:migrate

rails s -b `hostname -i`
```

8. Go to your browser and access `http://localhost:3000`