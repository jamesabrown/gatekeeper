FROM ruby:2.3.1
LABEL maintainer="James Brown <jbrown@thejbproject.com>"

WORKDIR /usr/src/gatekeeper
RUN gem install bundler -v '1.15.3'
COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY gatekeeper/ .
EXPOSE 4567
CMD ["bundle", "exec", "rackup", "-p", "4567", "-o", "0.0.0.0"]
