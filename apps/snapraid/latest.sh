#!/bin/bash

set -eux

VERSION_RAW=$(curl -sX GET "https://api.github.com/repos/amadvance/snapraid/releases/latest")

>&2 echo "${VERSION_RAW}"

VERSION=$(echo "${VERSION_RAW}" | jq -r .tag_name)

printf "${VERSION#*v}"