#!/bin/bash

source ./set_all_env_vars.sh

if [ ! -f "${JAR_FILE_PATH:?}" ]; then
  echo "Error: File '${JAR_FILE_PATH:?}' does not exist."
  exit 1
fi

set -x

# This is a classic template based pipeline.
# https://cloud.google.com/dataflow/docs/guides/templates/creating-templates
# https://cloud.google.com/dataflow/docs/guides/templates/running-templates

# # This will permanently fail
# PUB_SUB_INPUT_TOPIC="projects/fake-project-id/topics/fake-input-topic-name"
# PUB_SUB_INPUT_SUBSCRIPTION="projects/fake-project-id/subscriptions/fake-input-subscription-name"
# PUB_SUB_OUTPUT_TOPIC="projects/fake-project-id/topics/fake-output-topic-name"
# PUB_SUB_OUTPUT_SUBSCRIPTION="projects/fake-project-id/subscriptions/fake-output-subscription-name"

java -cp "${JAR_FILE_PATH:?}" \
  "${JAVA_MAIN_CLASS:?}" \
  --project="fake-project-id" \
  --region="us-central1" \
  --appName="PubSubToPubSubStreaming" \
  --jobName="fake-job-name" \
  --runner=DataflowRunner \
  --tempLocation="${GCS_PATH:?}/tmp" \
  --stagingLocation="${GCS_PATH:?}/staging" \
  --autoscalingAlgorithm=THROUGHPUT_BASED \
  --numWorkers=5 \
  --maxNumWorkers=5 \
  --dataflowServiceOptions="min_num_workers=5" \
  --enableStreamingEngine \
  --dataflowServiceOptions="streaming_mode_at_least_once" \
  --inputSubscription="${PUB_SUB_INPUT_SUBSCRIPTION:?}" \
  --outputTopic="${PUB_SUB_OUTPUT_TOPIC:?}" \
  --templateLocation="${CLASSIC_TEMPLATE_LOCATION:?}" \
;
