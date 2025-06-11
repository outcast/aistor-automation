#!/usr/bin/env bash

if [[ -z "$REPO_HOST" ]]; then
  REPO_HOST=$1
fi

export REPO_HOST=$REPO_HOST
if [[ -z "$REPO_HOST" ]]; then
  echo "Usage: $0 <repository-host>"
  exit 1
fi

# Set the prefixes for AISTOR and MinIO repositories
if [[ -z "$AISTOR_PREFIX" ]]; then
  AISTOR_PREFIX="minio/aistor/"
fi
if [[ -z "$MINIO_PREFIX" ]]; then
  MINIO_PREFIX="minio/"
fi

export AISTOR_PREFIX
export MINIO_PREFIX
# License key for MinIO, replace with your actual license key
if [[ -z "$MINIO_LICENSE" ]]; then
  MINIO_LICENSE="AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
fi
export MINIO_LICENSE


OPERATOR_VALUES=$(helm show values aistor/operators | yq '.repositories.aistor.hostname = strenv(REPO_HOST) | .repositories.aistor.pathPrefix = strenv(AISTOR_PREFIX) | .repositories.minio.hostname = strenv(REPO_HOST) | .repositories.minio.pathPrefix = strenv(MINIO_PREFIX) | .global.license = strenv(MINIO_LICENSE)')

# check for pull secret env variable
if [[ -n "$PULL_SECRET" ]]; then
  OPERATOR_VALUES=$(echo "$OPERATOR_VALUES" | yq '.global.operator.imagePullSecrets = "[{ \"name\": \""+strenv(PULL_SECRET)+"\",\"type\": \"kubernetes.io/dockerconfigjson\"}]"')
fi

echo "$OPERATOR_VALUES"