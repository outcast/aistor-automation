#!/usr/bin/env bash

AISTOR_IMAGES_SYNCED=""
declare -A repositories
repositories=(
    ["aistor"]="quay.io/minio/aistor"
    ["minio"]="quay.io/minio"
)

if [[ -z "$AISTOR_CACHE_DIR" ]]; then
    AISTOR_CACHE_DIR="/tmp/aistor/cache"
fi

if [[ -z "$IMAGE_PROJECT" ]]; then
    IMAGE_PROJECT="aistor"
fi

function check_command() {
  local cmd=$1
  if ! command -v "$cmd" &> /dev/null; then
    echo "Command '$cmd' not found. Please install it."
    return 1
  fi
  return 0
}

function skopeo_sync() {
  local src=$1
  local dest=$2
  local options=$3

  if [[ -z "$src" || -z "$dest" ]]; then
    echo "Usage: skopeo_sync <source> <destination> [options]"
    return 1
  fi

  skopeo sync --all --src docker --dest docker $options "$src" "$dest"
}

function setup_cache() {

    if [[ -z "$AISTOR_CACHE_DIR" ]]; then
        AISTOR_CACHE_DIR="/tmp/aistor/cache"
    fi

    if [[ ! -d "$AISTOR_CACHE_DIR" ]]; then
        mkdir -p "$AISTOR_CACHE_DIR"
    fi
    
    if [[ -d "$AISTOR_CACHE_DIR" ]]; then
       return 0
    else
        return 1
    fi
}

function is_aistor_operators_cached() {
    if [[ -d $AISTOR_CACHE_DIR ]]; then
        return 0
    else
        return 1
    fi
}

function aistor_airgap_sync() {
    local new_repo=$1
    local image_project=$IMAGE_PROJECT
    #local image_project
    
    if [[ -z "$new_repo" ]]; then
        echo "Usage: aistor_airgap_sync <new_repo>"
        return 1
    fi
    
    helm repo add aistor https://aistor.min.io/
    helm repo update aistor
    
    helm pull aistor/operators
    tar -xzf operators-*.tgz
    
    for image in $(sed '1,/defaultImages returns the default list of images/d' operators/templates/_helpers.tpl | grep -E -v '.*\{.*|.*\[.*|.*\]|.*\}.*' | yq '.[] | "quay.io/" + .repository + "/" + .image'); do
        IFS='/' read -r -a image_parts <<< "${image//://}"
        #echo ${image_parts[0]//\"/}
        image_name=${image_parts[$((${#image_parts[@]} - 2))]}
        image_tag=${image_parts[$((${#image_parts[@]} - 1))]}
        # if [[ -z "$image_tag" ]]; then
        #     image_tag=${image_parts[$((${#image_parts[@]} - 1))]}
        # else
        #     image_tag="latest"
        # fi
        echo $image ${image_parts[1]} ${repositories["aistor"]} ${repositories["${image_parts[1]}"]}/$image_name:${image_tag//\"/}
        echo skopeo_sync ${repositories["${image_parts[1]}"]}/$image_name:${image_tag//\"/} $new_repo/${image_parts[1]}
        skopeo_sync ${repositories["${image_parts[1]}"]}/$image_name:${image_tag//\"/} $new_repo/${image_parts[1]}
    done
}

function directpv_airgap_sync() {
    local new_repo=$1
    local image_project=$2
    
    if [[ -z "$new_repo" ]]; then
        echo "Usage: directpv_sync <new_repo> [image_project]"
        return 1
    fi
    
    for image in $(curl -sfL https://raw.githubusercontent.com/minio/directpv/refs/heads/master/resources/base/DaemonSet.yaml | grep "image:" | awk '{print $2}' | uniq); do
        IFS='/' read -r -a image_parts <<< "${image//@//}"
        image_name=${image_parts[$((${#image_parts[@]} - 2))]}
        image_tag=${image_parts[$((${#image_parts[@]} - 1))]}
        if [[ -z "$image_project" ]]; then
            image_project="directpv"
        fi
        echo $image ${image_parts[1]} ${repositories["${image_parts[1]}"]} ${repositories["${image_parts[1]}"]}/$image_name:${image_tag//\"/}
        echo skopeo_sync $image $new_repo/${image_parts[1]}/$image_name:latest
        # docker pull $image
        # docker tag $image $new_repo/${image_parts[1]}/$image_name
        # docker push $new_repo/${image_parts[1]}/$image_name:latest
        skopeo_sync $image $new_repo/${image_parts[1]}
    done
}
