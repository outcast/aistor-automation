#!/usr/bin/env bash

if [[ -z "$REPO_HOST" ]]; then
  REPO_HOST=$1
fi

export REPO_HOST=$REPO_HOST
if [[ -z "$REPO_HOST" ]]; then
  echo "Usage: $0 <repository-host>"
  exit 1
fi

export AISTOR_PREFIX="minio/aistor/"
export MINIO_PREFIX="minio/"
export MINIO_LICENSE="AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"


helm show values aistor/operators | yq '.repositories.aistor.hostname = strenv(REPO_HOST) | .repositories.aistor.pathPrefix = strenv(AISTOR_PREFIX) | .repositories.minio.hostname = strenv(REPO_HOST) | .repositories.minio.pathPrefix = strenv(MINIO_PREFIX) | .global.license = strenv(MINIO_LICENSE)'