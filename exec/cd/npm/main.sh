#!/bin/bash

echo ::group::Delivering npm package...

echo - Publishing package
! npm publish 2>&1 && {
    echo "::error::There was a problem publishing package for \"$CI_VERSION\"."
    exit 1
}

NAME="$(npm pkg get name --json | jq -r)"

echo "1. :package: [**npm**]\
(https://www.npmjs.com/package/$NAME/v/$CI_VERSION)" \
    >>"$GITHUB_STEP_SUMMARY"

echo ::endgroup::

exit 0
