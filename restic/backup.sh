#!/bin/bash

set -eu

# Env vars:
# RESTIC_REPOSITORY 
# RESTIC_FORGET_POLICY
# Parameters:
# 1: File containing backup paths

restic -r "${RESTIC_REPOSITORY}" snapshots &> /dev/null

if ! restic -r "${RESTIC_REPOSITORY}" snapshots; then
  echo "Initialising repository ${RESTIC_REPOSITORY}"
  restic -r "${RESTIC_REPOSITORY}" init
fi

echo "Starting backup"
restic -r "${RESTIC_REPOSITORY}" backup --files-from "${1}"

if [ -z "${RESTIC_FORGET_POLICY}" ]; then
  echo "Running forget"
  restic forget -r "${RESTIC_REPOSITORY}" ${RESTIC_FORGET_POLICY}
fi