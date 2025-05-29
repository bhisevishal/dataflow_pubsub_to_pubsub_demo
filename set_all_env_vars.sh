#!/bin/bash

# Check if the script is sourced
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
  echo "Error: This script should be sourced, not executed directly. Run as: source $0"
  exit 1
fi

source ./set_required_env_vars.sh

export BASE_DIR="."

export JAVA_MAIN_CLASS="com.examples.dataflow.PubSubToPubSubStreaming"
export JAR_FILE_NAME="dataflow-examples-1.0.jar"
export JAR_FILE_PATH="${BASE_DIR:?}/target/${JAR_FILE_NAME:?}"

export GCS_PATH="gs://${GCS_BUCKET_NAME:?}/users/${USER_ID:?}"

export CLASSIC_TEMPLATE_NAME="pubsub_to_pubsub_streaming_classic"
export CLASSIC_TEMPLATE_LOCATION="${GCS_PATH:?}/templates/classic/${CLASSIC_TEMPLATE_NAME:?}"

export AR_NAME="dev-flex-templates"
export AR_LOCATION="${REGION:?}"
export FLEX_TEMPLATE_NAME="pubsub_to_pubsub_streaming_flex"
export FLEX_TEMPLATE_LOCATION="${GCS_PATH:?}/templates/flex/${FLEX_TEMPLATE_NAME:?}"
export FLEX_TEMPLATE_METADATA_SOURCE_FILE_PATH="${BASE_DIR:?}/src/main/java/com/example/dataflow/pubsub_to_pubsub_flex_template_metadata.json"
export FLEX_TEMPLATE_IMAGE="${AR_LOCATION:?}-docker.pkg.dev/${PROJECT_ID:?}/${AR_NAME:?}/users/${USER_ID:?}/${FLEX_TEMPLATE_NAME:?}:latest"

PROJECT="${PROJECT_ID:?}"
PROJECT="${PROJECT_ID//:/\/}"  # Replace colons with slashes in the project id
export FLEX_TEMPLATE_IMAGE="${AR_LOCATION:?}-docker.pkg.dev/${PROJECT:?}/${AR_NAME:?}/users/${USER_ID:?}/${FLEX_TEMPLATE_NAME:?}:latest"

export PUB_SUB_INPUT_TOPIC_NAME="${USER_ID:?}-${REGION:?}-input-01"
export PUB_SUB_INPUT_SUBSCRIPTION_NAME="${PUB_SUB_INPUT_TOPIC_NAME}-sub-01"
export PUB_SUB_OUTPUT_TOPIC_NAME="${USER_ID:?}-${REGION:?}-output-01"
export PUB_SUB_OUTPUT_SUBSCRIPTION_NAME="${PUB_SUB_OUTPUT_TOPIC_NAME}-sub-01"

export PUB_SUB_INPUT_TOPIC="projects/${PROJECT_ID:?}/topics/${PUB_SUB_INPUT_TOPIC_NAME:?}"
# export PUB_SUB_INPUT_TOPIC="projects/pubsub-public-data/topics/taxirides-realtime"
export PUB_SUB_INPUT_SUBSCRIPTION="projects/${PROJECT_ID:?}/subscriptions/${PUB_SUB_INPUT_SUBSCRIPTION_NAME:?}"
export PUB_SUB_OUTPUT_TOPIC="projects/${PROJECT_ID:?}/topics/${PUB_SUB_OUTPUT_TOPIC_NAME:?}"
export PUB_SUB_OUTPUT_SUBSCRIPTION="projects/${PROJECT_ID:?}/subscriptions/${PUB_SUB_OUTPUT_SUBSCRIPTION_NAME:?}"

export JOB_NAME_PRODUCER_01="${USER_ID:?}-${REGION:?}-pubsub-producer-01"
export JOB_NAME_A="${USER_ID:?}-${REGION:?}-pubsub-to-pubsub-01"
export JOB_NAME_B="${USER_ID:?}-${REGION:?}-pubsub-to-pubsub-02"
