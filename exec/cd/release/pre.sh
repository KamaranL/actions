#!/bin/bash

echo ::group::Running exec-cd-release pre-checks...

# echo - Getting branch name
# PR_NUM="$(echo -e "$WFR_REF" | grep -oE '[0-9]{1,}')"
# BASE_REF="$(gh pr view "$PR_NUM" --json baseRefName --jq .baseRefName)"
# CI_TAG="v$(curl -s -H "Authorization: Token $GH_TOKEN" \
#     -L https://raw.githubusercontent.com/$GITHUB_REPOSITORY/${BASE_REF:-HEAD}/VERSION.txt)"

echo - Checking tag existence
[ -z "$CI_TAG" ] && {
    echo ::error::No tag is available for release.
    exit 1
}

echo - Checking release existence
gh release view "$CI_TAG" --repo "$GITHUB_REPOSITORY" >/dev/null 2>&1 && {
    echo "::error::A release already exists for \"$CI_TAG\"."
    exit 1
}

# echo "ci-tag=$CI_TAG" >>"$GITHUB_OUTPUT"

echo ::endgroup::

exit 0
