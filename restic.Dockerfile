FROM public.ecr.aws/lts/ubuntu:22.04_stable AS builder

ARG RESTIC_VERSION="0.14.0"

RUN apt update && apt install -y wget bzip2

RUN wget -O restic.bz2 "https://github.com/restic/restic/releases/download/v${RESTIC_VERSION}/restic_${RESTIC_VERSION}_linux_amd64.bz2"; \
  bunzip2 restic.bz2; \
  mv restic /usr/bin/restic; \
  chmod 755 /usr/bin/restic

FROM public.ecr.aws/lts/ubuntu:22.04_stable

COPY --from=builder /usr/bin/restic /usr/bin/restic
COPY restic/backup.sh /usr/bin/backup.sh
RUN chmod 755 /usr/bin/backup.sh