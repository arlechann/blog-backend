FROM ruby:3.1.1-slim

RUN apt-get update \
	&& apt-get install build-essential libpq-dev -y --no-install-recommends \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

RUN bundle config --global frozen 1

WORKDIR /opt/blog

COPY Gemfile Gemfile.lock ./
RUN bundle install

RUN apt-get remove build-essential -y \
	&& apt-get autoremove -y \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

COPY . .

CMD ["bundle", "exec", "rackup", "-s", "thin", "-o", "0.0.0.0", "-p", "4567"]

