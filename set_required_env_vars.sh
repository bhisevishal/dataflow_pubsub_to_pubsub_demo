#!/bin/bash

# Check if the script is sourced
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
  echo "Error: This script should be sourced, not executed directly. Run as: source $0"
  exit 1
fi

# Update these variables directly in the file as per your needs.
export USER_ID="${USER_ID:-${USER}}"
export PROJECT_ID="${PROJECT_ID:?}"
export GCS_BUCKET_NAME="${GCS_BUCKET_NAME:?}"  # e.g. "${PROJECT_ID##*:}"
export REGION="${REGION:-us-central1}"

# Verify that the environment variables are set and not empty.
echo "PROJECT_ID: ${PROJECT_ID:?}" 1> /dev/null
echo "GCS_BUCKET_NAME: ${GCS_BUCKET_NAME:?}" 1> /dev/null
echo "REGION: ${REGION:?}" 1> /dev/null
echo "USER_ID: ${USER_ID:?}" 1> /dev/null
