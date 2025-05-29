#!/bin/bash

source ./set_all_env_vars.sh

set -x

gcloud dataflow flex-template run "${JOB_NAME_PRODUCER_01:?}" \
  --template-file-gcs-location="gs://dataflow-templates-us-central1/latest/flex/Streaming_Data_Generator" \
  --project="${PROJECT_ID:?}" \
  --region="${REGION:?}" \
  --staging-location="${GCS_PATH:?}/staging" \
  --temp-location="${GCS_PATH:?}/tmp" \
  --enable-streaming-engine \
  --additional-user-labels="owner=${USER_ID:?}" \
  --additional-experiments="streaming_mode_at_least_once" \
  --parameters="schemaTemplate=GAME_EVENT,qps=2500,sinkType=PUBSUB,topic=${PUB_SUB_INPUT_TOPIC:?},autoscalingAlgorithm=NONE,numWorkers=1,maxNumWorkers=1,workerMachineType=n1-highmem-2" \
;
