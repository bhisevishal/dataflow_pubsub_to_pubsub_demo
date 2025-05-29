## Setup

Note: If you have never run a dataflow job before please try
https://cloud.google.com/dataflow/docs/guides/create-pipeline-java this will
help to enable all needed APIs. Also take look at
https://cloud.google.com/dataflow/docs/quickstarts/create-streaming-pipeline-template.

*   Open `./set_required_env_vars.sh` file and update env vars as per you needs.

```shell
# Update these variables directly in the file as per your needs.
export USER_ID="${USER}"
export PROJECT_ID=""
export GCS_BUCKET_NAME=""  # e.g. "${PROJECT_ID##*:}"
export REGION="us-central1"
```

*   Verify env variables

```shell
./echo_all_env_vars.sh
```

Note: If you don't like to use scripts for running dataflow jobs then directly
set all env vars used in this demo.

```shell
source ./set_all_env_vars.sh
```

### Create GCS bucket

```shell
./gcs_setup.sh
```

or

```
gcloud storage buckets create "gs://${GCS_BUCKET_NAME:?}" --project="${PROJECT_ID:?}"
```

### Create Pubsub Topics and Subscriptions

```
./pubsub_setup.sh
```

or

```
gcloud pubsub topics create "${PUB_SUB_INPUT_TOPIC:?}" \
  --message-retention-duration="7d" \
;

gcloud pubsub subscriptions create "${PUB_SUB_INPUT_SUBSCRIPTION:?}" \
  --topic="${PUB_SUB_INPUT_TOPIC:?}" \
  --message-retention-duration="7d" \
  --retain-acked-messages \
  --ack-deadline="120" \
;

gcloud pubsub topics create "${PUB_SUB_OUTPUT_TOPIC:?}" \
  --message-retention-duration="7d" \
;

gcloud pubsub subscriptions create "${PUB_SUB_OUTPUT_SUBSCRIPTION:?}" \
  --topic="${PUB_SUB_OUTPUT_TOPIC:?}" \
  --message-retention-duration="7d" \
  --retain-acked-messages \
  --ack-deadline="120" \
;
```

## Build

### Build Java Jar

```shell
./build_jar.sh
```

### Build Classic Template

```shell
./build_classic_template.sh
```

### Build Flex Template

```shell
./build_flex_template.sh
```

## Start Producer pipeline

Note: If you like to skip starting producer pipeline then in
`set_required_env_vars.sh` then set `PUB_SUB_INPUT_TOPIC` to
`projects/pubsub-public-data/topics/taxirides-realtime` and `source
./set_all_env_vars.sh`. This is a pubsub public topic, check
https://cloud.google.com/dataflow/docs/quickstarts/create-streaming-pipeline-template.

```
./run_pubsub_producer_pipeline.sh
```

or

```
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
```

## Start Consumer Pipeline using Jar, Flex Template or Classic Template

### Start Consumer Pipeline using Jar

```shell
./run_pubsub_consumer_pipeline_using_jar_file.sh
```

or

```shell
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
```

### Start Consumer Pipeline using Flex Template

```shell
./run_pubsub_consumer_pipeline_using_flex_template.sh
```

or

```shell
# This is a flex template based pipeline.
# https://cloud.google.com/dataflow/docs/guides/templates/using-flex-templates

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
;
```

### Start Consumer Pipeline using Classic Template

```shell
./run_pubsub_consumer_pipeline_using_classic_template.sh
```

or

```shell
# This is a classic template based pipeline.
# https://cloud.google.com/dataflow/docs/guides/templates/creating-templates
# https://cloud.google.com/dataflow/docs/guides/templates/running-templates

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
```

## Inplace update

### Inplace update using Jar

```shell
./in_place_update_pubsub_consumer_pipeline_using_jar_file.sh
```

or

```shell
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
  --update \
;
```

### Inplace update using Flex Template

```shell
./in_place_update_pubsub_consumer_pipeline_using_flex_template.sh
```

or

```shell
# This is a flex template based pipeline.
# https://cloud.google.com/dataflow/docs/guides/templates/using-flex-templates

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
```

### Inplace update using Classic Template

```shell
./in_place_update_pubsub_consumer_pipeline_using_classic_template.sh
```

or

```shell
# This is a classic template based pipeline.
# https://cloud.google.com/dataflow/docs/guides/templates/creating-templates
# https://cloud.google.com/dataflow/docs/guides/templates/running-templates

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
  --update \
;
```

## Cleanup

### Purge Pubsub Messages

```shell
./pubsub_purge_all_messages.sh
```

or

```shell
gcloud pubsub subscriptions seek "${PUB_SUB_OUTPUT_SUBSCRIPTION:?}" \
  --time=$(date -u +%Y-%m-%dT%H:%M:%SZ) \
;

gcloud pubsub subscriptions seek "${PUB_SUB_INPUT_SUBSCRIPTION:?}" \
  --time=$(date -u +%Y-%m-%dT%H:%M:%SZ) \
;
```

### Delete pubsub subscriptions and topic

```shell
./pubsub_cleanup.sh
```

or

```shell
gcloud pubsub subscriptions delete "${PUB_SUB_OUTPUT_SUBSCRIPTION:?}" \
;

gcloud pubsub topics delete "${PUB_SUB_OUTPUT_TOPIC:?}" \
;

gcloud pubsub subscriptions delete "${PUB_SUB_INPUT_SUBSCRIPTION:?}" \
;

gcloud pubsub topics delete "${PUB_SUB_INPUT_TOPIC:?}" \
;
```

### Cleanup Jar files and generated files

```shell
./cleanup_jar_and_generated_files.sh
```

or

```
mvn clean
rm dependency-reduced-pom.xml
```
