#!/bin/bash

set -eu

PREFIX="ghcr.io/samsimpson1/"

for IMAGE in snapraid restic; do
  docker build . -t "${PREFIX}${IMAGE}:latest" -f "${IMAGE}.Dockerfile"
  docker push "${PREFIX}${IMAGE}:latest"
done