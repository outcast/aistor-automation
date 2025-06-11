#!/usr/bin/env bash


if [[ -z "$OBJS_NAME" ]]; then
  OBJS_NAME=$1
fi
if [[ -z "$OBJS_POOL_NAME" ]]; then
  OBJS_POOL_NAME=$2
fi
if [[ -z "$OBJS_SERVER_COUNT" ]]; then
  OBJS_SERVER_COUNT=$3
fi
if [[ -z "$OBJS_VOLUME_COUNT" ]]; then
  OBJS_VOLUME_COUNT=$4
fi
if [[ -z "$OBJS_VOLUME_CAPACITY" ]]; then
  OBJS_VOLUME_CAPACITY=$5
fi
if [[ -z "$OBJS_VOLUME_STORAGE_CLASS" ]]; then
  OBJS_VOLUME_STORAGE_CLASS=$6
fi


if [[ -z "$OBJS_NAME" ]]; then
  OBJS_NAME="object-store"
fi
if [[ -z "$OBJS_POOL_NAME" ]]; then
  OBJS_POOL_NAME="pool-0"
fi
if [[ -z "$OBJS_SERVER_COUNT" ]]; then
  OBJS_SERVER_COUNT=1
fi
if [[ -z "$OBJS_VOLUME_COUNT" ]]; then
  OBJS_VOLUME_COUNT=1
fi
if [[ -z "$OBJS_VOLUME_CAPACITY" ]]; then
  OBJS_VOLUME_CAPACITY="1Gi"
fi
if [[ -z "$OBJS_VOLUME_STORAGE_CLASS" ]]; then
  OBJS_VOLUME_STORAGE_CLASS="standard"
fi
export OBJS_NAME
export OBJS_POOL_NAME
export OBJS_SERVER_COUNT
export OBJS_VOLUME_COUNT
export OBJS_VOLUME_CAPACITY
export OBJS_VOLUME_STORAGE_CLASS

#print usage
if [[ $1 == "-h" ]]; then
  echo "Usage: $0 <object-store-name> <pool-name> <server-count> <volume-count> <volume-capacity> <volume-storage-class>"
  echo "Example: $0 object-store pool-0 1 1 1Gi standard"
  exit 1
fi


echo "## Generating object store values with the following parameters:"
echo "##  Object Store Name: $OBJS_NAME"
echo "##  Pool Name: $OBJS_POOL_NAME"
echo "##  Server Count: $OBJS_SERVER_COUNT"
echo "##  Volume Count: $OBJS_VOLUME_COUNT"
echo "##  Volume Capacity: $OBJS_VOLUME_CAPACITY"
echo "##  Volume Storage Class: $OBJS_VOLUME_STORAGE_CLASS"

OBJS_VALUES=$(helm show values aistor/object-store | yq '
.objectStore.name = strenv(OBJS_NAME) |
.objectStore.pools[0].name = strenv(OBJS_POOL_NAME) | 
.objectStore.pools[0].servers = (strenv(OBJS_SERVER_COUNT) | tonumber) | 
.objectStore.pools[0].volumesPerServer = strenv(OBJS_VOLUME_COUNT) | 
.objectStore.pools[0].size = strenv(OBJS_VOLUME_CAPACITY) | 
.objectStore.pools[0].storageClassName = strenv(OBJS_VOLUME_STORAGE_CLASS) 
')

if [[ -n "$PULL_SECRET" ]]; then
  OBJS_VALUES=$(echo "$OBJS_VALUES" | yq '.objectStore.imagePullSecret.name = strenv(PULL_SECRET) | .objectStore.imagePullSecret.type = "kubernetes.io/dockerconfigjson"')
fi

echo "$OBJS_VALUES"