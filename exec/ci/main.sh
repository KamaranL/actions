#!/bin/bash

echo "::group::Integrating code base..."

echo "- Amending commit"
! git commit -a --amend --no-edit --date=now 2>&1 && {
    echo "::error::There was a problem with amending the latest changes."
    exit 1
}

CI_SHA="$(git rev-parse HEAD)"
CI_ORIGIN="$CI_SHA:$CI_SOURCE_BRANCH"
CI_TAG="v$CI_VERSION"

echo "- Creating tag: $CI_TAG"
! git tag -a "$CI_TAG" -m "$CI_TAG" "$CI_SHA" 2>&1 && {
    echo "::error::There was a problem with creating tag \"$CI_TAG\"."
    exit 1
} || echo "- :label: $CI_TAG" \
    >>"$GITHUB_STEP_SUMMARY"

echo "- Pushing changes to origin: $CI_ORIGIN"
! git push origin "$CI_ORIGIN" --force-with-lease 2>&1 && {
    echo "::error::There was a problem with pushing changes to origin."
    exit 1
}

gh pr comment "$GITHUB_EVENT_NUMBER" --body "This pull request can now be \
merged." 2>&1

# base branch might not be updated right away, so loop through merge attempts
MERGED=false
MAX_ATTEMPTS=10
for ((i = 1; i <= MAX_ATTEMPTS; i++)); do
    echo "- Merging pull request: $GITHUB_EVENT_NUMBER \
(attempt $i/$MAX_ATTEMPTS)"
    gh pr merge "$GITHUB_EVENT_NUMBER" --merge 2>&1 && {
        MERGED=true
        break
    }
    sleep 0.5
done

! $MERGED &&
    echo "::error::There was a problem with merging pull request \
#$GITHUB_EVENT_NUMBER. This pull request will need to be merged manually." ||
    echo "- (#$GITHUB_EVENT_NUMBER) $CI_TARGET_BRANCH :arrow_left: \
$CI_SOURCE_BRANCH" >>"$GITHUB_STEP_SUMMARY"

echo "::endgroup::"

exit 0
