#!/bin/bash

VERSION=$(bash latest.sh)

docker build . -t "ghcr.io/samsimpson1/snapraid:${VERSION}" --build-arg VERSION="${VERSION}"
docker push "ghcr.io/samsimpson1/snapraid:${VERSION}"