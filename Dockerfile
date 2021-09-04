FROM ruby:2.7-bullseye AS builder

ENV DEBIAN_FRONTEND=noninteractive \
  RAILS_ENV=production \
  NODE_ENV=production \
  GEM_HOME=/app/.gem \
	BUNDLE_APP_CONFIG=/app/.bundle

ARG VERSION=master

RUN set -eux; \
  git clone --depth 1 https://github.com/discourse/discourse.git -b $VERSION -c advice.detachedHead=false /app/current; \
  echo 'deb https://dl.yarnpkg.com/debian/ stable main' > /etc/apt/sources.list.d/yarn.list; \
  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -; \
  curl -sL https://deb.nodesource.com/setup_14.x | bash -; \
  apt-get update; \
  apt-get install --yes --no-install-recommends nodejs yarn; \
  cd /app/current; \
  gem install bundler; \
  bundle config without 'test development'; \
  bundle install --jobs 8; \
  yarn install; \
  rm -rf /var/lib/apt/lists /app/.gem/cache /app/current/.git


FROM ruby:2.7-slim-bullseye

ENV DEBIAN_FRONTEND=noninteractive \
  RAILS_ENV=production \
  NODE_ENV=production \
  GEM_HOME=/app/.gem \
	BUNDLE_APP_CONFIG=/app/.bundle

RUN set -eux; \
  apt-get update; \
  apt-get install --yes --no-install-recommends \
    advancecomp brotli jhead jpegoptim libjpeg-turbo-progs imagemagick optipng pngcrush gifsicle pngquant \
    nodejs nginx-light libpq5; \
  rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder /app .
COPY files/* /app/

VOLUME /app/shared

CMD /app/puma
