#!/usr/bin/env sh

set -eu

unset CI_COMMIT_TAG UNSET_COMMIT_BRANCH

case "${1:-}" in
    tag)
        if [ -z "${2:+notempty}" ]; then
            >&2 printf 'Tag pipeline needs a tag name, but none was supplied\n'
            exit 1
        fi
        CI_COMMIT_TAG="$2"
        UNSET_COMMIT_BRANCH=1
        ;;

    branch)
        ;;
esac

gitlab-ci-local \
    ${CONTAINER_EXECUTABLE:+--container-executable "$CONTAINER_EXECUTABLE"} \
    ${CI_COMMIT_TAG:+--variable CI_COMMIT_TAG="$CI_COMMIT_TAG"} \
    ${UNSET_COMMIT_BRANCH:+--variable CI_COMMIT_BRANCH=}
