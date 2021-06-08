# This is our DEVELOPMENT dockerfile.
FROM ruby:3.0.0-buster  AS development

WORKDIR /app
ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock
RUN bundle config set with 'development'
RUN bundle install

EXPOSE 3000

COPY . .

CMD ["rails", "server", "-b", "0.0.0.0"]

FROM ruby:3.0.0-buster  AS production

ENV RAILS_ENV production

WORKDIR /app
ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock
RUN bundle config set with 'production'
RUN bundle install --without development

EXPOSE 3000

COPY . .

CMD ["rails", "server", "-b", "0.0.0.0", "-e", "production"]