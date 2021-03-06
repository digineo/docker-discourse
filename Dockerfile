
# ------------------------------
# First stage

FROM ubuntu:focal AS builder

ENV DEBIAN_FRONTEND=noninteractive
ARG VERSION=master
ARG RUBYGEMS_VERSION=3.2.17

RUN set -ex; \
  apt-get update; \
  apt-get install --yes --no-install-recommends \
    build-essential git ruby ruby-dev libssl-dev \
    libxml2-dev libxslt-dev zlib1g-dev libpq-dev libreadline-dev; \
  rm -rf /var/lib/apt/lists/*; \
  gem update --system $RUBYGEMS_VERSION --no-document; \
  rm -rfv /usr/bin/bundle*2.7 /usr/lib/ruby/2.7.0/bundler*; \
  ln -fs /var/lib/gems/2.7.0/gems/rubygems-update-$RUBYGEMS_VERSION/bundler/lib/bundler.rb /usr/lib/ruby/2.7.0/bundler.rb; \
  ln -fs /var/lib/gems/2.7.0/gems/rubygems-update-$RUBYGEMS_VERSION/bundler/lib/bundler /usr/lib/ruby/2.7.0/bundler; \
  ln -fs /var/lib/gems/2.7.0/gems/rubygems-update-$RUBYGEMS_VERSION/bundler/exe/bundle /usr/bin/bundle;

RUN git clone --depth 1 https://github.com/discourse/discourse.git -b $VERSION -c advice.detachedHead=false /app/current && rm -rf /app/current/.git*

RUN set -ex; \
  cd /app/current; \
  bundle config --local deployment 'true'; \
  bundle config --local without 'test development'; \
  bundle config --local path vendor/bundle; \
  bundle install --jobs `nproc`

# ------------------------------
# Seconds stage

FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive
ENV RAILS_ENV=production
ENV NODE_ENV=production
ARG CADDY_VERSION=2.4.1
ARG RUBYGEMS_VERSION=3.2.17

WORKDIR /app
COPY --from=builder /app .

RUN set -ex; \
  apt-get update; \
  apt-get install --yes --no-install-recommends \
    ruby libxml2 libxslt1.1 libpq5 \
    curl git gnupg \
    advancecomp brotli jhead jpegoptim libjpeg-turbo-progs imagemagick optipng pngcrush gifsicle pngquant; \
  echo 'deb https://dl.yarnpkg.com/debian/ stable main' > /etc/apt/sources.list.d/yarn.list; \
  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -; \
  curl -sL https://deb.nodesource.com/setup_14.x | bash -; \
  apt-get install --yes --no-install-recommends \
    nodejs yarn; \
  gem update --system $RUBYGEMS_VERSION --no-document; \
  rm -rfv /usr/bin/bundle*2.7 /usr/lib/ruby/2.7.0/bundler*; \
  ln -fs /var/lib/gems/2.7.0/gems/rubygems-update-$RUBYGEMS_VERSION/bundler/lib/bundler.rb /usr/lib/ruby/2.7.0/bundler.rb; \
  ln -fs /var/lib/gems/2.7.0/gems/rubygems-update-$RUBYGEMS_VERSION/bundler/lib/bundler /usr/lib/ruby/2.7.0/bundler; \
  ln -fs /var/lib/gems/2.7.0/gems/rubygems-update-$RUBYGEMS_VERSION/bundler/exe/bundle /usr/bin/bundle; \
  curl -fsLo /tmp/caddy.deb https://github.com/caddyserver/caddy/releases/download/v$CADDY_VERSION/caddy_${CADDY_VERSION}_linux_amd64.deb; \
  dpkg -i /tmp/caddy.deb; \
  rm -rf /tmp/*.deb /var/lib/apt/lists/*; \
  yarn install


VOLUME /app/shared

COPY files/* /app/

CMD /app/puma
