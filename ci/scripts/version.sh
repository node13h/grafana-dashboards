#!/usr/bin/env sh

# Validate version source is correct and write an env file with version
# variants and flags.

set -eu

OUTPUT_FILE="$1"
truncate -s 0 "$OUTPUT_FILE"

write_var () {
    printf '%s=%s\n' "$1" "$2" | tee -a "$OUTPUT_FILE" >&2
}

default_branch_sha=$(git rev-parse "$CI_DEFAULT_BRANCH")
write_var DEFAULT_BRANCH_SHA "$default_branch_sha"

version=$(cat VERSION)

if [ -n "${IS_TAGGED_RELEASE:-}" ]; then
    # Verify if the version source matches the version being released.
    if [ "$CI_COMMIT_TAG" != "v${version}" ]; then
        >&2 printf -- 'Version "%s" does not match the version "%s" in the Git tag\n' "$version" "${CI_COMMIT_TAG#v}"
        exit 1
    fi

    if [ "$default_branch_sha" = "$CI_COMMIT_SHA" ]; then
        write_var IS_LATEST_RELEASE 1
    fi

    write_var VERSION_SEMVER "$version"
else
    # Force the user to increment version number after release.
    if git show-ref --tags "refs/tags/v${version}" >/dev/null; then
        >&2 printf 'Version %s appears to be already released. Please bump the version number in VERSION\n' "$version"
        exit 1
    fi

    commit_count=$(git rev-list --count HEAD)
    write_var VERSION_SEMVER "${version}-${commit_count}-${CI_COMMIT_SHORT_SHA}"
fi
