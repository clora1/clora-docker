#!/usr/bin/env bash

set -eu

cd "$(cd "${0%/*}" && pwd -P)"

source ./common.sh

function get_images() {
  local prefix
  prefix=${1:-.}

  local images

  for dir in ${prefix%/}/*/; do
    if [ -f "$dir/Dockerfile" ] && [ -x "$dir/update.sh" ]; then
      images+=( "${dir#./}" )
    fi
  done

  echo "${images[@]%/}"
}

function update() {
  local images

  images=("$@")
  for image in "${images[@]}"; do
    info "Updating $image..."

    pushd "$image"

    ./update.sh | sed -e "s/^/ [$image] /g"

    if [ ${PIPESTATUS[0]} -ne "0" ] ; then
      error "Error updating $image"
      exit 1
    fi
    popd

    success "Dockerfile updated"
  done
}

function maybe_build() {
  local images changed

  images=("$@")
  for image in "${images[@]}"; do
    changed+=("${image}/Dockerfile")
    if [[ -n $(git status --porcelain "$image/Dockerfile") ]]; then
      if ask "Dockerfile for $image modified. Run a clean build locally?" Y; then
        TAG=clora/$image

        pushd "$image"
        docker build --quiet --tag=${TAG} . 1>/dev/null
        docker image ls --format "Docker image {{.Repository}}:{{.Tag}} is {{.Size}}" ${TAG}
        popd
      fi
    fi
  done

  if [ ${#changed[@]} -gt 0 ]; then
    info "Files updated, add via:"
    success " git add${changed[*]}"
  fi
}

IFS=' ' read -ra images <<< $(get_images)

update ${images[@]}
success "Updated all images"
maybe_build ${images[@]}
