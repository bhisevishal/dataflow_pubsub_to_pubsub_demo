#!/bin/bash

source ./set_all_env_vars.sh

if [ ! -f "${JAR_FILE_PATH:?}" ]; then
  echo "Error: File '${JAR_FILE_PATH:?}' does not exist."
  exit 1
fi


set -x

# This is a flex template based pipeline.
# https://cloud.google.com/dataflow/docs/guides/templates/using-flex-templates

# Create an artifacts repository if it doesn't exist.
gcloud artifacts repositories describe "${AR_NAME:?}" \
  --location "${AR_LOCATION:?}" \
  --project "${PROJECT_ID:?}" \
  &> /dev/null || \
  gcloud artifacts repositories create "${AR_NAME:?}" \
  --repository-format docker \
  --location "${AR_LOCATION:?}" \
  --project "${PROJECT_ID:?}" \
  || echo "Failed to create artifacts repository" \
;

# Use bash subshell so that we can restore the working directory after the build.
( 
  # Create a temporary directory to copy the JAR file and metadata file.
  TMP_DIR_BASE="/tmp/dataflow-flex-template-build"
  mkdir -p "${TMP_DIR_BASE:?}"
  TMP_DIR="$(mktemp -d --tmpdir="${TMP_DIR_BASE:?}")"
  mkdir -p "${TMP_DIR:?}"
  cp "${JAR_FILE_PATH:?}" "${TMP_DIR:?}/";
  cp "${FLEX_TEMPLATE_METADATA_SOURCE_FILE_PATH:?}" "${TMP_DIR:?}/${FLEX_TEMPLATE_NAME:?}_metadata";

  # Change to the temporary directory to build the flex template.
  pushd "${TMP_DIR:?}"
  pwd
  ls -la
  gcloud dataflow flex-template build "${FLEX_TEMPLATE_LOCATION:?}" \
    --image-gcr-path "${FLEX_TEMPLATE_IMAGE:?}" \
    --sdk-language "JAVA" \
    --flex-template-base-image "JAVA21" \
    --jar "${JAR_FILE_NAME:?}" \
    --env "FLEX_TEMPLATE_JAVA_MAIN_CLASS=${JAVA_MAIN_CLASS:?}" \
    --project "${PROJECT_ID:?}" \
    && echo "Successfully created flex template ${FLEX_TEMPLATE_LOCATION:?}" \
  ;
  popd
  rm -rf "${TMP_DIR:?}"
)
