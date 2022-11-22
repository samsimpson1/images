FROM public.ecr.aws/lts/ubuntu:22.04_stable AS builder

RUN apt update && apt install -y build-essential bison dpkg-dev libgdbm-dev wget autoconf zlib1g-dev libreadline-dev checkinstall git

# Compile OpenSSL 1.1.1
RUN set -eux; \
    wget -O openssl.tar.gz "https://www.openssl.org/source/openssl-1.1.1s.tar.gz"; \
    echo "c5ac01e760ee6ff0dab61d6b2bbd30146724d063eb322180c6f18a6f74e4b6aa openssl.tar.gz" | sha256sum --check; \
    mkdir -p /usr/src/openssl; \
    tar -xf openssl.tar.gz -C /usr/src/openssl --strip-components=1; \
    cd /usr/src/openssl; \
    ./config --prefix=/opt/openssl --openssldir=/opt/openssl shared zlib; \
    make; \
    make install_sw;  # Avoid building manpages and such.

# Compile ruby
# Build Ruby
RUN set -eux; \
    \
    wget -O ruby.tar.xz "https://cache.ruby-lang.org/pub/ruby/3.0/ruby-3.0.4.tar.xz"; \
    echo "8e22fc7304520435522253210ed0aa9a50545f8f13c959fe01a05aea06bef2f0 *ruby.tar.xz" | sha256sum --check --strict; \
    \
    mkdir -p /usr/src/ruby /build; \
    tar -xJf ruby.tar.xz -C /usr/src/ruby --strip-components=1; \
    rm ruby.tar.xz; \
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
      --with-openssl-dir=/opt/openssl \
    ; \
    make -j "$(nproc)"; \
    make install;

# Fetch Mastodon

RUN git clone https://github.com/tootsuite/mastodon.git /opt/mastodon; \
  cd /opt/mastodon; \
  git checkout v4.0.2;

FROM public.ecr.aws/lts/ubuntu:22.04_stable

# Install dependencies
RUN apt update && DEBIAN_FRONTEND=noninteractive TZ=Europe/London apt install -y git ca-certificates curl gpg nginx imagemagick file tzdata build-essential libicu-dev libpq-dev libidn-dev zlib1g-dev && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | gpg --dearmor | tee "/usr/share/keyrings/nodesource.gpg" >/dev/null && \
    echo "deb [signed-by=/usr/share/keyrings/nodesource.gpg] https://deb.nodesource.com/node_16.x jammy main" | tee /etc/apt/sources.list.d/nodesource.list && \
    apt update && apt install -y nodejs && rm -r /var/lib/apt/lists /var/cache/apt/archives && npm i -g yarn

# Copy OpenSSL and link in system castore
COPY --from=builder /opt/openssl /opt/openssl
RUN rmdir /opt/openssl/certs; \
    ln -s /etc/ssl/certs /opt/openssl/certs

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
COPY mastodon/01-precompile /etc/cont-init.d/01-precompile
COPY mastodon/web /etc/services.d/mastodon-web/run
COPY mastodon/sidekiq /etc/services.d/mastodon-sidekiq/run
COPY mastodon/nginx.conf /etc/nginx/nginx.conf
COPY mastodon/nginx /etc/services.d/nginx/run
RUN chmod 755 /etc/cont-init.d/* /etc/services.d/**/run

ENTRYPOINT ["/init"]