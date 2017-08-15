FROM ruby:2.3.1

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/
RUN bundle install

COPY . /usr/src/app

CMD ["bundle", "exec", "rackup", "-p", "4567", "-o", "0.0.0.0"]
