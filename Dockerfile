FROM ruby:2.6.0

WORKDIR /app

COPY Gemfile* ./
RUN bundle install

COPY . .

ENTRYPOINT [ "rerun", "ruby", "main.rb", "tcp://upstream:80"]
