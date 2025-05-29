#!/bin/bash
set -x

# Note: If add dataflow-runner profile, then use following command
# mvn -Pdataflow-runner -DskipTests clean package

mvn -DskipTests clean package
