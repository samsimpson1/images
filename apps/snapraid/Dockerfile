FROM public.ecr.aws/lts/ubuntu:22.04_stable AS builder

ARG VERSION

RUN apt update && apt install -y wget build-essential

RUN set -eux; \
  wget -O snapraid.tar.gz "https://github.com/amadvance/snapraid/releases/download/v${VERSION}/snapraid-${VERSION}.tar.gz"; \
  mkdir -p /usr/src/snapraid /build; \
  tar -xvf snapraid.tar.gz -C /usr/src/snapraid --strip-components=1; \
  cd /usr/src/snapraid; \
  ./configure --prefix=/build; \
  make; \
  make install

FROM public.ecr.aws/lts/ubuntu:22.04_stable

COPY --from=builder /build /usr