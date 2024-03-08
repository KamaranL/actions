#!/bin/bash

echo "::group::Delivering GitHub Release"

ARGS="release create $CI_TAG --latest --generate-notes --verify-tag --repo $GITHUB_REPOSITORY"

[ ! -z "$INPUT_ASSETS" ] &&
    ARGS+=" $INPUT_ASSETS/*"

! gh $ARGS 2>&1 && {
    echo "::error::There was a problem creating a release for \"$CI_TAG\"."
    exit 1
}

echo "Release \"$CI_TAG\" can be found at https://github.com/$GITHUB_REPOSITORY/releases/latest." >>"$GITHUB_STEP_SUMMARY"

echo "::endgroup::"

exit 0
