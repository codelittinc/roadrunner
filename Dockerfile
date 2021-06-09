FROM ruby:3.0.0-buster

ARG ENVIRONMENT
ARG SECRET_KEY_BASE
RUN echo "Running Dockerfile with the environment: ${ENVIRONMENT}"

WORKDIR /app
ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock
RUN bundle config set with ${ENVIRONMENT}
RUN bundle install

EXPOSE 3000

COPY . .

ENV RAILS_ENV ${ENVIRONMENT}

CMD ["rails", "server", "-b", "0.0.0.0"]