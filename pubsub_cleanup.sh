#!/bin/bash

source ./set_all_env_vars.sh

set -x

gcloud pubsub subscriptions describe "${PUB_SUB_OUTPUT_SUBSCRIPTION:?}" &> /dev/null && \
gcloud pubsub subscriptions delete "${PUB_SUB_OUTPUT_SUBSCRIPTION:?}" \
;

gcloud pubsub topics describe "${PUB_SUB_OUTPUT_TOPIC:?}" &> /dev/null && \
gcloud pubsub topics delete "${PUB_SUB_OUTPUT_TOPIC:?}" \
;

gcloud pubsub subscriptions describe "${PUB_SUB_INPUT_SUBSCRIPTION:?}" &> /dev/null && \
gcloud pubsub subscriptions delete "${PUB_SUB_INPUT_SUBSCRIPTION:?}" \
;

gcloud pubsub topics describe "${PUB_SUB_INPUT_TOPIC:?}" &> /dev/null && \
gcloud pubsub topics delete "${PUB_SUB_INPUT_TOPIC:?}" \
;
