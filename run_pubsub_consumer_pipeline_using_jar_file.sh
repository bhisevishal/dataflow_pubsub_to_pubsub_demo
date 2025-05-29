#!/bin/bash

source ./set_all_env_vars.sh

set -x

# Keeping same number of workers for demo purpose.
java -cp "${JAR_FILE_PATH:?}" \
  "${JAVA_MAIN_CLASS:?}" \
  --project="${PROJECT_ID:?}" \
  --region="${REGION:?}" \
  --appName="PubSubToPubSubStreaming" \
  --jobName=${JOB_NAME_A:?} \
  --runner=DataflowRunner \
  --tempLocation="${GCS_PATH:?}/tmp" \
  --stagingLocation="${GCS_PATH:?}/staging" \
  --labels='{ "owner": "'${USER_ID:?}'" }' \
  --autoscalingAlgorithm=THROUGHPUT_BASED \
  --numWorkers=5 \
  --maxNumWorkers=5 \
  --dataflowServiceOptions="min_num_workers=5" \
  --enableStreamingEngine \
  --dataflowServiceOptions="streaming_mode_at_least_once" \
  --inputSubscription="${PUB_SUB_INPUT_SUBSCRIPTION:?}" \
  --outputTopic="${PUB_SUB_OUTPUT_TOPIC:?}" \
;
