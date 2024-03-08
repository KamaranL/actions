#!/bin/bash

echo "::group::Delivering GitHub Release"

ARGS="release create $TAG --latest --generate-notes --verify-tag"

[ ! -z "$INPUT_ASSETS" ] &&
    ARGS+=" $INPUT_ASSETS/*"

! gh "$ARGS" 2>&1 && {
    echo "::error::There was a problem creating a release for \"$TAG\"."
    exit 1
}

echo "Release \"$TAG\" can be found at https://github.com/$GITHUB_REPOSITORY/releases/latest."

echo "::endgroup::"

exit 0
