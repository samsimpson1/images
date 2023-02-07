#!/bin/bash

VERSION=$(curl -sX GET "https://api.github.com/repos/mastodon/mastodon/releases/latest" | jq -r .tag_name)

printf "${VERSION#*v}"