#!/bin/bash

# CI_TAG="$(gh api /repos/$GITHUB_REPOSITORY/tags --jq '.[0].name')" #old method

# get base branch from pr that triggered workflow
PR_NUM="$(echo -e "$WORKFLOW_REF" | grep -oE '[0-9]{1,}')"
BASE_REF="$(gh pr view "$PR_NUM" --json baseRefName --jq .baseRefName)"
CI_TAG="v$(curl -s -H "Authorization: Token $GH_TOKEN" \
    -L https://raw.githubusercontent.com/$GITHUB_REPOSITORY/${BASE_REF:-HEAD}/VERSION.txt)"

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
