#!/bin/bash

VERSION=$(bash latest.sh)

docker build . -t "ghcr.io/samsimpson1/roon:${VERSION}"
docker push "ghcr.io/samsimpson1/roon:${VERSION}"