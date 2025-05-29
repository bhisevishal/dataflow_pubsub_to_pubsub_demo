#!/bin/bash

source ./set_all_env_vars.sh

set -x

gcloud pubsub topics describe "${PUB_SUB_INPUT_TOPIC:?}" &> /dev/null || \
gcloud pubsub topics create "${PUB_SUB_INPUT_TOPIC:?}" \
  --message-retention-duration="7d" \
;

gcloud pubsub subscriptions describe "${PUB_SUB_INPUT_SUBSCRIPTION:?}" &> /dev/null || \
gcloud pubsub subscriptions create "${PUB_SUB_INPUT_SUBSCRIPTION:?}" \
  --topic="${PUB_SUB_INPUT_TOPIC:?}" \
  --message-retention-duration="7d" \
  --retain-acked-messages \
  --ack-deadline="120" \
;

gcloud pubsub topics describe "${PUB_SUB_OUTPUT_TOPIC:?}" &> /dev/null || \
gcloud pubsub topics create "${PUB_SUB_OUTPUT_TOPIC:?}" \
  --message-retention-duration="7d" \
;

gcloud pubsub subscriptions describe "${PUB_SUB_OUTPUT_SUBSCRIPTION:?}" &> /dev/null || \
gcloud pubsub subscriptions create "${PUB_SUB_OUTPUT_SUBSCRIPTION:?}" \
  --topic="${PUB_SUB_OUTPUT_TOPIC:?}" \
  --message-retention-duration="7d" \
  --retain-acked-messages \
  --ack-deadline="120" \
;
