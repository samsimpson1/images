#!/bin/bash

VERSION_STR=$(curl -sX GET "https://updates.roonlabs.com/update/?v=2&platform=linux&product=RoonServer&branch=production&branding=roon&version=1&curbranch=production" | grep machineversion | awk '{ split($0, a, "="); print a[2]; }')

printf "${VERSION_STR}"
