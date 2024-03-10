## Setting up a local development environment

### Install prerequisites

- [gitlab-ci-local](https://github.com/firecow/gitlab-ci-local).
- Podman or Docker
- GNU Make

### Define local CI variables

Use the following example to create `.gitlab-ci-local-variables.yml`.

```shell
{
    read -rp 'GitHub token: ' dockerhub_user
    read -rsp 'DockerHub token: ' dockerhub_token
    dockerhub_auth=$(printf '%s:%s' "$dockerhub_user" "$dockerhub_token" | base64)

    cat <<EOF >.gitlab-ci-local-variables.yml
---
GITHUB_OWNER: 'node13h'
GITHUB_REPO: 'grafana-dashboards'
GITHUB_TOKEN: '${github_token}'
EOF
}
```

## Running builds locally

Run `make pipeline` to run the pipeline defined in [.gitlab-ci.yml](.gitlab-ci.yml).

See [Makefile](Makefile) for more details.

## Releasing

To build and publish the rendered dashboards as GitHub artifacts

- Create an annotated (to track the release date) Git tag using `vX.Y.Z` format.
  `X.Y.Z` must match the version in [VERSION](VERSION).
- Push the tag to GitHub.
- Ensure the Git working tree is clean.
- Run `make tag-pipeline`.
- Increment the version number in [VERSION](VERSION) and commit the change.

## Updating Grafonnet

Run `make update-deps` to update Grafonnet library and it's dependencies.
