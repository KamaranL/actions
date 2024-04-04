#!/bin/bash

echo ::group::bash "$0"

args="release create $CI_TAG --latest --generate-notes --verify-tag"

[ ! -z "$INPUTS_ASSETS" ] &&
    args+=" $INPUTS_ASSETS/*"

echo - Creating release
! gh $args 2>&1 && {
    echo "::error::There was a problem creating a release for \"$CI_TAG\"."
    exit 1
}

echo "- :package: [**github (release)**]\
(https://github.com/$GITHUB_REPOSITORY/releases/tag/$CI_TAG)" \
    >>"$GITHUB_STEP_SUMMARY"

echo ::endgroup::

exit 0
