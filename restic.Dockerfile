FROM public.ecr.aws/lts/ubuntu:22.04_stable AS builder

ARG RESTIC_VERSION="0.14.0"

RUN apt update && apt install -y wget bzip2

RUN wget -O restic.bz2 "https://github.com/restic/restic/releases/download/v${RESTIC_VERSION}/restic_${RESTIC_VERSION}_linux_amd64.bz2"; \
  bunzip2 restic.bz2; \
  mv restic /usr/bin/restic; \
  chmod 755 /usr/bin/restic

RUN wget -O autorestic.bz2 "https://github.com/cupcakearmy/autorestic/releases/download/v1.7.4/autorestic_1.7.4_linux_amd64.bz2"; \
  bunzip autorestic.bz2; \
  mv autorestic /usr/bin/autorestic; \
  chmod 755 /usr/bin/autorestic

FROM public.ecr.aws/lts/ubuntu:22.04_stable

RUN apt update && apt install -y ca-certificates && rm -r /var/lib/apt/lists /var/cache/apt/archives
COPY --from=builder /usr/bin/restic /usr/bin/restic
COPY --from=builder /usr/bin/autorestic /usr/bin/autorestic