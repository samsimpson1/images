FROM public.ecr.aws/lts/ubuntu:22.04_stable AS builder

ARG VERSION

RUN apt update && apt install -y wget tar bzip2

WORKDIR /opt/roon

RUN mkdir /roon; \
  wget -O /roon.tar.bz2 "https://download.roonlabs.net/updates/production/RoonServer_linuxx64_${VERSION}.tar.bz2"; \
  tar -xvjf /roon.tar.bz2 -C /roon --strip-components=1

FROM public.ecr.aws/lts/ubuntu:22.04_stable

RUN apt update && apt install -y ffmpeg libasound2 cifs-utils && \
  rm -r /var/lib/apt/lists /var/cache/apt/archives

WORKDIR /opt/roon

COPY --from=builder /roon ./

ENV ROON_DATAROOT="/data"

CMD [ "/bin/bash", "-c", "/opt/roon/start.sh"]