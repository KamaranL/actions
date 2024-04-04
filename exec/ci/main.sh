#!/bin/bash

echo ::group::bash "$0"

echo - Amending commit
! git commit -a --amend --no-edit --date=now 2>&1 && {
    echo ::error::There was a problem with amending the latest changes.
    exit 1
}

sha="$(git rev-parse HEAD)"
origin="$sha:$CI_SOURCE_BRANCH"
tag="v$CI_VERSION"

echo - Creating tag: "$tag"
! git tag -a "$tag" -m "$tag" "$sha" 2>&1 && {
    echo "::error::There was a problem with creating tag \"$tag\"."
    exit 1
} || echo "- :label: **$tag**" >>"$GITHUB_STEP_SUMMARY"

echo - Pushing changes to origin: "$origin"
! git push origin "$origin" --force-with-lease 2>&1 && {
    echo ::error::There was a problem with pushing changes to origin.
    exit 1
}

gh pr comment "$GITHUB_EVENT_NUMBER" --body "This pull request can now be \
merged." 2>&1

# base branch might not be updated right away, so loop through merge attempts
merged=false
max_attempts=10
for ((i = 1; i <= max_attempts; i++)); do
    echo "- Merging #$GITHUB_EVENT_NUMBER (attempt $i of $max_attempts)"

    gh pr merge "$GITHUB_EVENT_NUMBER" --merge 2>&1 && {
        merged=true
        break
    }
    sleep 0.5
done

! $merged &&
    echo "::error::There was a problem with merging pull request \
#$GITHUB_EVENT_NUMBER. This pull request will need to be merged manually." ||
    echo "- **$CI_TARGET_BRANCH** :arrow_left: **$CI_SOURCE_BRANCH**" \
        >>"$GITHUB_STEP_SUMMARY"

echo ::endgroup::

exit 0
