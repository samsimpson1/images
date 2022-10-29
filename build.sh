#!/bin/bash

set -eu

PREFIX="ghcr.io/samsimpson1/"

for IMAGE in snapraid; do
  docker build . -t "${PREFIX}${IMAGE}:latest" -f "${image}.Dockerfile"
  docker push "${PREFIX}${IMAGE}:latest"
done