#!/bin/bash

# CI_TAG="$(gh api /repos/$GITHUB_REPOSITORY/tags --jq '.[0].name')" #old method

CI_TAG="vß$(curl -s -H "Authorization: Token $GH_TOKEN" \
    -L https://raw.githubusercontent.com/$GITHUB_REPOSITORY/${WORKFLOW_RUN_BASE_REF:-HEAD}/VERSION.txt)"
# https://raw.githubusercontent.com/{repo}/{branch}/VERSION.txt

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
