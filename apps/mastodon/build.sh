#!/bin/bash

set -eux

VERSION=$(bash latest.sh)

docker build . -t "ghcr.io/samsimpson1/mastodon:${VERSION}" --build-arg VERSION="${VERSION}"
docker push "ghcr.io/samsimpson1/mastodon:${VERSION}"