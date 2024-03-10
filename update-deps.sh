#!/usr/bin/env sh

set -eu

CONTAINER_EXECUTABLE="${CONTAINER_EXECUTABLE:-docker}"
CI_JSONNET_IMAGE=$(yq -re .variables.CI_JSONNET_IMAGE .gitlab-ci.yml)

container=$("$CONTAINER_EXECUTABLE" create --workdir /tmp "$CI_JSONNET_IMAGE" jb update)
"$CONTAINER_EXECUTABLE" cp jsonnetfile.json "${container}:/tmp"
"$CONTAINER_EXECUTABLE" cp jsonnetfile.lock.json "${container}:/tmp"
"$CONTAINER_EXECUTABLE" start -a "$container"
"$CONTAINER_EXECUTABLE" cp "${container}:/tmp/jsonnetfile.lock.json" jsonnetfile.lock.json
"$CONTAINER_EXECUTABLE" rm "$container"
