FROM ruby:3.1.1

RUN bundle config --global frozen 1

WORKDIR /opt/blog

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

CMD ["bundle", "exec", "rackup", "-s", "thin", "-o", "0.0.0.0", "-p", "4567"]

