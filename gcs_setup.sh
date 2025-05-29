#!/bin/bash

source ./set_all_env_vars.sh

set -x

gcloud storage buckets describe "gs://${GCS_BUCKET_NAME:?}" --project="${PROJECT_ID:?}" &> /dev/null || \
gcloud storage buckets create "gs://${GCS_BUCKET_NAME:?}" --project="${PROJECT_ID:?}"
