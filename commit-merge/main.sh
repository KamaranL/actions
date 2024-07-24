#!/usr/bin/env bash

echo ::group::bash "$0"

echo - Amending commit
! git commit -a --amend --no-edit --date=now 2>&1 && {
    echo ::error::There was a problem with amending the latest changes.
    echo ::endgroup::
    exit 1
}

commit="$(git rev-parse HEAD)"

git verify-commit "$commit" 2>&1 &&
    echo - :white_check_mark: "$commit" >>"$GITHUB_STEP_SUMMARY"

tag="v$CI_VERSION"
major="v${CI_VERSION:0:1}"

echo - Creating tag: "$tag"
! git tag -m "$tag" "$tag" "$commit" 2>&1 && {
    echo ::error::There was a problem with creating tag \""$tag"\".
    echo ::endgroup::
    exit 1
} || {
    echo "- :label: **$tag**" >>"$GITHUB_STEP_SUMMARY"
    git verify-tag "$tag" 2>&1 &&
        echo - :white_check_mark: "$tag" >>"$GITHUB_STEP_SUMMARY"
}

echo - Updating major release tag: "$major"
! git tag -fm "$major" "$major" "$commit" 2>&1 && {
    echo ::error::There was a problem with updating tag \""$major"\".
    echo ::endgroup::
    exit 1
} || {
    git verify-tag "$major" 2>&1 &&
        echo - :white_check_mark: "$major" >>"$GITHUB_STEP_SUMMARY"
}

if [ -f action.yml ] &&
    [ "$(git tag | sort -r --version-sort | head -1)" == "$tag" ]; then
    echo - Updating release tag: latest
    ! git tag -fm latest latest "$commit" 2>&1 && {
        echo ::error::There was a problem with updating tag \"latest\".
        echo ::endgroup::
        exit 1
    } || {
        git verify-tag latest 2>&1 &&
            echo - :white_check_mark: latest >>"$GITHUB_STEP_SUMMARY"
    }
fi

origin="$commit:$CI_SOURCE_BRANCH"

echo - Pushing changes to origin: "$origin"
! git push origin "$origin" --force-with-lease 2>&1 && {
    echo ::error::There was a problem with pushing changes to origin.
    echo ::endgroup::
    exit 1
}

echo - Pushing updated tags
! git push origin -f --tags 2>&1 && {
    echo ::error::There was a problem with pushing updated tags to origin.
    echo ::endgroup::
    exit 1
}

gh pr comment "$GITHUB_EVENT_NUMBER" --body "This pull request can now be \
merged." 2>&1

## base branch might not be updated right away... so, loop through attempts
merged=false
max_attempts=10
for ((i = 1; i <= max_attempts; i++)); do
    echo "- Merging #$GITHUB_EVENT_NUMBER (attempt $i of $max_attempts)"
    gh pr merge "$GITHUB_EVENT_NUMBER" --merge 2>&1 && {
        merged=true
        break
    }
    sleep 1
done

! $merged &&
    echo ::error::There was a problem with merging pull request \
        \#"$GITHUB_EVENT_NUMBER". This pull request will need to be merged \
        manually. ||
    echo "- **$CI_TARGET_BRANCH** :arrow_left: **$CI_SOURCE_BRANCH**" \
        >>"$GITHUB_STEP_SUMMARY"

echo ::endgroup::

exit 0
