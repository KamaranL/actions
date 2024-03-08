#!/bin/bash

CI_TAG="$(gh api /repos/$GITHUB_REPOSITORY/tags --jq '.[0].name')"

# check tag existence
[ -z "$CI_TAG" ] && {
    echo "::error::No tag is available for release."
    exit 1
}

# check release existence
gh release view "$CI_TAG" --repo "$GITHUB_REPOSITORY" >/dev/null 2>&1 && {
    echo "::error::A release already exists for \"$CI_TAG\"."
    exit 1
}

echo "ci-tag=$CI_TAG" >>"$GITHUB_OUTPUT"

exit 0
