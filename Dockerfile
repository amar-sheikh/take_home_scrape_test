FROM ruby:3.0.2
WORKDIR .
COPY Gemfile* ./
RUN bundle install
COPY . ./
