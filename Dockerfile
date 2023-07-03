FROM ruby:2.7.3

RUN apt-get update -yqq
RUN apt-get install -yqq --no-install-recommends nodejs

COPY . /usr/src/app

WORKDIR /usr/src/app

RUN bundle

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
