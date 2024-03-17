#!/usr/bin/env sh

set -eu

gitlab-ci-local \
    --file .local-tasks.yml \
    ${CONTAINER_EXECUTABLE:+--container-executable "$CONTAINER_EXECUTABLE"} \
    --artifacts-to-source=true \
    "$1"
