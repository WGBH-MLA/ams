ARG HYRAX_IMAGE_VERSION=hyrax-v5.0.0.rc1
FROM ghcr.io/samvera/hyrax/hyrax-base:$HYRAX_IMAGE_VERSION as ams-base
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
    libreoffice \
    libxml2-dev \
    mariadb-dev \
    mediainfo \
    nodejs \
    openjdk17-jre \
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
    wget https://github.com/harvard-lts/fits/releases/download/1.5.5/fits-1.5.5.zip -O fits.zip && \
    unzip fits.zip && \
    rm fits.zip && \
    chmod a+x /app/fits/fits.sh
ENV PATH="${PATH}:/app/fits"

RUN rm -f /app/samvera/rails
COPY --chown=1001:101 $APP_PATH/Gemfile* /app/samvera/hyrax-webapp/
RUN bundle install --jobs "$(nproc)"

# NOTE Bootboot enablement
# COPY --chown=1001:101 $APP_PATH/Gemfile /app/samvera/hyrax-webapp/Gemfile_next
# RUN DEPENDENCIES_NEXT=1 bundle install --jobs "$(nproc)"

COPY --chown=1001:101 $APP_PATH /app/samvera/hyrax-webapp
ARG SETTINGS__BULKRAX__ENABLED="false"

# NOTE Bootboot enablement
# RUN sh -l -c " \
#   DEPENDENCIES_NEXT=1 yarn install && \
#   SOLR_URL=localhost DEPENDENCIES_NEXT=1 RAILS_ENV=production SECRET_KEY_BASE=fake-key-for-asset-building-only DB_ADAPTER=nulldb bundle exec rake assets:precompile"

RUN sh -l -c " \
  NODE_OPTIONS=--openssl-legacy-provider SOLR_URL=http://localhost:8983 RAILS_ENV=production SECRET_KEY_BASE=fake-key-for-asset-building-only DB_ADAPTER=nulldb bundle exec rake assets:precompile"

CMD ./bin/web

FROM ams-base as ams-worker
CMD ./bin/worker
