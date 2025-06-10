#!/usr/bin/env bash

AISTOR_CACHE_DIR="/tmp/aistor/cache"
IMAGE_PROJECT="$2"
NEW_REPO="$1"
source _helpers.sh

if ! check_command "skopeo"; then
    echo "skopeo command not found. Please install it.":32
    fdd
    exit 1
fi

if ! check_command "yq"; then
    echo "yq command not found. Please install it."
    exit 1
fi

if ! check_command "helm"; then
    echo "helm command not found. Please install it."
    exit 1
fi

if ! is_aistor_operators_cached; then
    echo "AISTOR operators are not cached. Setting up cache..."
    if ! setup_cache; then
        echo "Failed to set up cache directory at $AISTOR_CACHE_DIR. Please check permissions."
        exit 0
    fi
fi

aistor_airgap_sync "$NEW_REPO" aistor
directpv_airgap_sync "$NEW_REPO" minio
