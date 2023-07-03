# Official base image for Ruby 2.7.3
FROM ruby:2.7.3

# Install NodeJS for Rails
RUN apt-get update -yqq
RUN apt-get install -yqq --no-install-recommends nodejs

COPY . /usr/src/app

WORKDIR /usr/src/app

# Bundle gems
RUN gem update --system
RUN bundle config set force_ruby_platform true
RUN bundle

EXPOSE 3000

# Run the server bound to 0.0.0.0
CMD ["rails", "server", "-b", "0.0.0.0"]
