FROM public.ecr.aws/lts/ubuntu:22.04_stable AS builder

ARG VERSION

RUN apt update && apt install -y build-essential bison dpkg-dev libgdbm-dev wget autoconf zlib1g-dev libreadline-dev checkinstall git libyaml-dev libtool libssl-dev

# Build Ruby
RUN set -eux; \
    \
    wget -O ruby.tar.gz "https://cache.ruby-lang.org/pub/ruby/3.2/ruby-3.2.2.tar.gz"; \
    echo "96c57558871a6748de5bc9f274e93f4b5aad06cd8f37befa0e8d94e7b8a423bc *ruby.tar.gz" | sha256sum --check --strict; \
    \
    mkdir -p /usr/src/ruby /build; \
    tar -xf ruby.tar.gz -C /usr/src/ruby --strip-components=1; \
    rm ruby.tar.gz; \
    \
    cd /usr/src/ruby; \
    \
    { \
      echo '#define ENABLE_PATH_CHECK 0'; \
      echo; \
      cat file.c; \
    } > file.c.new; \
    mv file.c.new file.c; \
    \
    autoconf; \
    gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; \
    ./configure \
      --build="$gnuArch" \
      --disable-install-doc \
      --enable-shared \
      --with-destdir=/build \
    ; \
    make -j "$(nproc)"; \
    make install;

# Fetch Mastodon

RUN git clone https://github.com/tootsuite/mastodon.git /opt/mastodon; \
  cd /opt/mastodon; \
  git checkout v${VERSION};

FROM public.ecr.aws/lts/ubuntu:22.04_stable

# Install dependencies
RUN apt update && DEBIAN_FRONTEND=noninteractive TZ=Europe/London apt install -y git ca-certificates curl gpg nginx imagemagick file tzdata build-essential libicu-dev libpq-dev libidn-dev zlib1g-dev libyaml-0-2 && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | gpg --dearmor | tee "/usr/share/keyrings/nodesource.gpg" >/dev/null && \
    echo "deb [signed-by=/usr/share/keyrings/nodesource.gpg] https://deb.nodesource.com/node_16.x jammy main" | tee /etc/apt/sources.list.d/nodesource.list && \
    apt update && apt install -y nodejs && rm -r /var/lib/apt/lists /var/cache/apt/archives && npm i -g yarn

# Copy Ruby binaries from builder image
COPY --from=builder /build /

# Copy Mastodon from builder image
COPY --from=builder /opt/mastodon /opt/mastodon

ENV RAILS_ENV=production

# Install dependencies
RUN cd /opt/mastodon; \
  bundle config deployment 'true'; \
  bundle config without 'development test'; \
  bundle install; \
  yarn install --pure-lockfile

# Install s6 overlay
ARG S6_OVERLAY_VERSION="3.1.2.1"
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz
ENV S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0

# Install service files
COPY files/01-precompile /etc/cont-init.d/01-precompile
COPY files/web /etc/services.d/mastodon-web/run
COPY files/sidekiq /etc/services.d/mastodon-sidekiq/run
COPY files/nginx.conf /etc/nginx/nginx.conf
COPY files/nginx /etc/services.d/nginx/run
RUN chmod 755 /etc/cont-init.d/* /etc/services.d/**/run

ENTRYPOINT ["/init"]

LABEL org.opencontainers.image.source https://github.com/mastodon/mastodon