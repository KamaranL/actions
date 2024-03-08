#!/bin/bash

TAG="$(gh api /repos/$GITHUB_REPOSITORY/tags --jq '.[0].name')"

# check tag existence
[ ! -z "$TAG" ] && {
    echo "::error::No tag is available for release."
    exit 1
}

# check release existence
gh release view "$TAG" --repo "$GITHUB_REPOSITORY" >/dev/null 2>&1 && {
    echo "::error::A release already exists for \"$TAG\"."
    exit 1
}

echo "tag=$TAG" >>"$GITHUB_OUTPUT"

exit 0
