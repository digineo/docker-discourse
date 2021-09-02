FROM ruby:2.7-bullseye

ENV DEBIAN_FRONTEND=noninteractive
ENV RAILS_ENV=production
ENV NODE_ENV=production

ARG VERSION=master

RUN git clone --depth 1 https://github.com/discourse/discourse.git -b $VERSION -c advice.detachedHead=false /app/current && rm -rf /app/current/.git*

WORKDIR /app

RUN set -ex; \
  echo 'deb https://dl.yarnpkg.com/debian/ stable main' > /etc/apt/sources.list.d/yarn.list; \
  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -; \
  curl -sL https://deb.nodesource.com/setup_14.x | bash -; \
  apt-get update; \
  apt-get install --yes --no-install-recommends \
    advancecomp brotli jhead jpegoptim libjpeg-turbo-progs imagemagick optipng pngcrush gifsicle pngquant \
    nodejs yarn nginx-light; \
  rm -rf /var/lib/apt/lists/*; \
  cd /app/current; \
  gem install bundler --no-document; \
  bundle config --local deployment 'true'; \
  bundle config --local without 'test development'; \
  bundle install --jobs 8; \
  yarn install


VOLUME /app/shared

COPY files/* /app/

CMD /app/puma
