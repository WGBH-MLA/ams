ARG HYRAX_IMAGE_VERSION=3.1.0
FROM ghcr.io/samvera/hyku/hyku-base:$HYRAX_IMAGE_VERSION as ams-base

USER root

RUN apk --no-cache upgrade && \
  apk --no-cache add \
    bash \
    cmake \
    curl \
    curl-dev \
    exiftool \
    ffmpeg \
    less \
    libcurl \
    libxml2-dev \
    mariadb-dev \
    mediainfo \
    nodejs \
    openjdk11-jre \
    openssh \
    perl \
    pkgconfig \
    rsync \
    screen \
    vim \
    yarn && \
  # curl https://sh.rustup.rs -sSf | sh -s -- -y && \
  # source "$HOME/.cargo/env" && \
  # cargo install rbspy && \
  echo "******** Packages Installed *********"

USER app

RUN mkdir -p /app/fits && \
    cd /app/fits && \
    wget https://github.com/harvard-lts/fits/releases/download/1.5.0/fits-1.5.0.zip -O fits.zip && \
    unzip fits.zip && \
    rm fits.zip && \
    chmod a+x /app/fits/fits.sh
ENV PATH="${PATH}:/app/fits"

COPY --chown=1001:101 $APP_PATH/Gemfile* /app/samvera/hyrax-webapp/
RUN bundle install --jobs "$(nproc)"

COPY --chown=1001:101 $APP_PATH /app/samvera/hyrax-webapp

ARG SETTINGS__BULKRAX__ENABLED="false"
RUN sh -l -c " \
  yarn install && \
  RAILS_ENV=production SECRET_KEY_BASE=fake-key-for-asset-building-only DB_ADAPTER=nulldb bundle exec rake assets:precompile"

CMD ./bin/web

FROM ams-base as ams-worker
ENV MALLOC_ARENA_MAX=2
CMD ./bin/worker