#!/bin/bash

VERSION=$(curl -sX GET "https://api.github.com/repos/amadvance/snapraid/releases/latest" | jq -r .tag_name)

printf "${VERSION#*v}"