#!/bin/bash

source ./set_all_env_vars.sh

set -x

# This is a classic template based pipeline.
# https://cloud.google.com/dataflow/docs/guides/templates/creating-templates
# https://cloud.google.com/dataflow/docs/guides/templates/running-templates
#
# Keeping same number of workers for demo purpose.
gcloud dataflow jobs run "${JOB_NAME_A:?}" \
  --gcs-location="${CLASSIC_TEMPLATE_LOCATION:?}" \
  --project="${PROJECT_ID:?}" \
  --region=${REGION:?} \
  --staging-location="${GCS_PATH:?}/staging" \
  --enable-streaming-engine \
  --additional-experiments="streaming_mode_at_least_once" \
  --parameters="inputSubscription=${PUB_SUB_INPUT_SUBSCRIPTION:?},outputTopic=${PUB_SUB_OUTPUT_TOPIC:?}" \
  --num-workers=5 \
  --max-workers=5 \
  --additional-experiments="min_num_workers=5" \
;
