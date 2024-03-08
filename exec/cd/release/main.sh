#!/bin/bash

echo "::group::Delivering GitHub Release"

CMD="release create $CI_TAG --latest --generate-notes --verify-tag"

[ ! -z "$INPUT_ASSETS" ] &&
    CMD+=" $INPUT_ASSETS/*"

! gh $CMD 2>&1 && {
    echo "::error::There was a problem creating a release for \"$CI_TAG\"."
    exit 1
}

echo "Release \"$CI_TAG\" can be found at https://github.com/$GITHUB_REPOSITORY/releases/latest."

echo "::endgroup::"

exit 0
