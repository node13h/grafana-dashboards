#!/usr/bin/env python3

import argparse
import json
import logging
import os
import pathlib
import sys
import urllib.parse
import urllib.request

logger = logging.getLogger(__name__)


# Assume the tag has already been pushed to the repo.
def gh_create_release(
    owner: str, repo: str, tag: str, commit_sha: str, token: str
) -> dict:

    url = "https://api.github.com/{}".format(
        urllib.request.pathname2url(f"repos/{owner}/{repo}/releases")
    )

    data = json.dumps(
        {
            "tag_name": tag,
            "target_commitish": commit_sha,
            "name": tag,
            "body": f"Release {tag}",
            "draft": False,
            "prerelease": False,
            "generate_release_notes": False,
        }
    ).encode("utf-8")

    headers = {
        "Accept": "application/vnd.github+json",
        "Authorization": f"Bearer {token}",
        "X-GitHub-Api-Version": "2022-11-28",
    }

    try:
        response = urllib.request.urlopen(
            urllib.request.Request(url=url, data=data, headers=headers, method="POST")
        )
    except urllib.error.HTTPError as e:
        if e.code == 422:
            logger.error(
                "GitHub release validation failed (already exists?). HTTP CODE 422"
            )
            sys.exit(1)
        else:
            raise

    response = json.load(response)

    logger.info("Created release {}".format(response["id"]))

    return response


def gh_upload_asset(
    owner: str, repo: str, release_id: str, asset_file: pathlib.Path, token: str
) -> dict:

    url = "https://uploads.github.com/{}?name={}".format(
        urllib.request.pathname2url(
            f"repos/{owner}/{repo}/releases/{release_id}/assets"
        ),
        urllib.parse.quote_plus(asset_file.name),
    )

    file_size = os.stat(asset_file).st_size

    headers = {
        "Accept": "application/vnd.github+json",
        "Authorization": f"Bearer {token}",
        "X-GitHub-Api-Version": "2022-11-28",
        "Content-Type": "application/octet-stream",
        "Content-Length": str(file_size),
    }

    with open(asset_file, "rb") as f:
        response = json.load(
            urllib.request.urlopen(
                urllib.request.Request(url=url, data=f, headers=headers, method="POST")
            )
        )

        logger.info(f"Uploaded {asset_file.name}")

        return response


def main():
    logging.basicConfig(level=logging.INFO)

    parser = argparse.ArgumentParser()

    parser.add_argument("files", nargs="+", type=pathlib.Path)
    args = parser.parse_args()

    tag = os.environ["CI_COMMIT_TAG"]
    commit_sha = os.environ["CI_COMMIT_SHA"]
    owner = os.environ["GITHUB_OWNER"]
    repo = os.environ["GITHUB_REPO"]
    token = os.environ["GITHUB_TOKEN"]

    release = gh_create_release(owner, repo, tag, commit_sha, token)

    for asset_file in args.files:
        gh_upload_asset(owner, repo, release["id"], asset_file, token)


if __name__ == "__main__":
    main()
