FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive

RUN set -ex; \
  apt-get update; \
  apt-get install --yes --no-install-recommends \
    build-essential brotli curl git gnupg ruby ruby-dev \
    libxml2-dev libxslt-dev zlib1g-dev libpq-dev libreadline-dev \
    advancecomp jhead jpegoptim libjpeg-turbo-progs imagemagick optipng pngcrush gifsicle pngquant; \
  echo 'deb https://dl.yarnpkg.com/debian/ stable main' > /etc/apt/sources.list.d/yarn.list; \
  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -; \
  curl -sL https://deb.nodesource.com/setup_12.x | bash -; \
  apt-get install --yes --no-install-recommends \
    nodejs yarn; \
  rm -rf /var/lib/apt/lists/*

RUN gem update --system --no-document && ln -s /usr/bin/bundle2.7 /usr/bin/bundle
RUN groupadd -r discourse && useradd --no-log-init -r -g discourse --home /app discourse
RUN git clone --depth 1 https://github.com/discourse/discourse.git /app/current

WORKDIR /app
COPY files/* /app/
RUN chown discourse:discourse -R . && su discourse ./install

VOLUME /app/shared
EXPOSE 3000

CMD ["su", "discourse", "/app/puma"]
