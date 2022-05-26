# syntax=docker/dockerfile:1
FROM ruby:2.7.5

RUN bundle config --global frozen 1

ADD . .

RUN gem install bundler:2.3.13
RUN bundle install

EXPOSE 3000

ENTRYPOINT [ "bundle", "exec" ]