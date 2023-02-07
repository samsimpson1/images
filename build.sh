#!/bin/bash

set -eu

APP="${1}"

cd "apps/${APP}"

bash build.sh