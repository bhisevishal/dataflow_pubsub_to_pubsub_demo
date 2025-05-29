#!/bin/bash

source ./set_all_env_vars.sh

set -x

gcloud pubsub subscriptions describe "${PUB_SUB_OUTPUT_SUBSCRIPTION:?}" &> /dev/null && \
gcloud pubsub subscriptions seek "${PUB_SUB_OUTPUT_SUBSCRIPTION:?}" --time=$(date -u +%Y-%m-%dT%H:%M:%SZ) \
;

gcloud pubsub subscriptions describe "${PUB_SUB_INPUT_SUBSCRIPTION:?}" &> /dev/null && \
gcloud pubsub subscriptions seek "${PUB_SUB_INPUT_SUBSCRIPTION:?}" --time=$(date -u +%Y-%m-%dT%H:%M:%SZ) \
;
