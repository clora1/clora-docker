#!/usr/bin/env bash

set -eu

source ../common.sh

DOCKERFILE=${1:-Dockerfile}

## Settings

# Alpine does snapshot releases every 6 months rather than having a release
# cycle tied to features. It's probably best to just stay one version behind
# bleeding edge, but we need to be vigilant not to lag too far behind.
ALPINE_VERSION=3.6

# This will pick the latest patch of minor release specified
RUBY_VERSION=2.4

# Node does things a little differently, and uses the major version more like
# Ruby uses the minor. LTS releases are tied to the major, not minor.
NODE_VERSION=8

NODE_DOCKERFILE_URL="https://raw.githubusercontent.com/nodejs/docker-node/master/$NODE_VERSION/alpine/Dockerfile"


info "Grabbing latest Node $NODE_VERSION.x Alpine Dockerfile"

# Get the specified Dockerfile, strip out any lines starting with CMD or FROM,
# and then kill any blank leading lines and trailing lines.
NODE_TEMPLATE=$(/usr/bin/curl -fsSL "$NODE_DOCKERFILE_URL" |
  grep -Ev "^(CMD|FROM) " |
  sed -e '/./,$!d' |
  ${TAC_CMD} |
  sed -e '/./,$!d' |
  ${TAC_CMD})


info "Writing out Dockerfile"

cat <<- EOF > ${DOCKERFILE}
${DOCKERFILE_HEADER}

# This Dockerfile combines the official Ruby Docker image with the official
# Node Docker image. Since Docker doesn't support anything like an "INCLUDE"
# directive, we start with an Alpine-based Ruby image and then tack on the
# source of an Alpine-based Node Docker image directly from GitHub. When
# upstream updates, it's necessary to refresh and rebuild this image.
#
# For a detialed discussion regarding an INCLUDE directive in Dockerfiles,
# see this issue: https://github.com/moby/moby/issues/735.

FROM ruby:${RUBY_VERSION}-alpine${ALPINE_VERSION}

${NODE_TEMPLATE}

CMD [ "bash" ]
EOF
