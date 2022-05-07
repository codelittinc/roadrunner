![CI](https://github.com/codelittinc/roadrunner-rails/workflows/CI/badge.svg)

## Getting startedasd

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

## Configuring Tasks on Heroku

1. Once inside your application on Heroku
2. Click ***Resources***, then click in ***Find more add-ons***.
3. Search for ***Heroku Scheduler*** and click on it.
4. Add your application on the field *App to provision to* and then click on *Provision add-on* button.
5. Inside the Heroku Scheduler now, you can add a job so, click on *Add Job* button
    1. Choose an interval to run this job
    2. Enter with the command to run the task. For example: 
    ```rake server:check_up_servers```
    3. Save the job and it's done.
6. You can also know about it here: [Heroku Scheduler](https://devcenter.heroku.com/articles/scheduler)
