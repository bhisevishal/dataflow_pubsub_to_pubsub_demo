#!/bin/bash

source ./set_all_env_vars.sh

set -x

# This is a flex template based pipeline.
# https://cloud.google.com/dataflow/docs/guides/templates/using-flex-templates
#
# This is an in-place update job.
# This job will update the existing job with name ${JOB_NAME_A:?} with new job with name ${JOB_NAME_A:?}
#
# Keeping same number of workers for demo purpose.
gcloud dataflow flex-template run "${JOB_NAME_A:?}" \
  --template-file-gcs-location="${FLEX_TEMPLATE_LOCATION:?}" \
  --project="${PROJECT_ID:?}" \
  --region=${REGION:?} \
  --staging-location="${GCS_PATH:?}/staging" \
  --temp-location="${GCS_PATH:?}/tmp" \
  --enable-streaming-engine \
  --additional-experiments="streaming_mode_at_least_once" \
  --parameters="inputSubscription=${PUB_SUB_INPUT_SUBSCRIPTION:?},outputTopic=${PUB_SUB_OUTPUT_TOPIC:?}" \
  --num-workers=5 \
  --max-workers=5 \
  --additional-experiments="min_num_workers=5" \
  --update \
;
