#!/bin/bash

echo ::group::bash "$0"

echo - Publishing package
! npm publish 2>&1 && {
    echo "::error::There was a problem publishing package for \"$CI_VERSION\"."
    exit 1
}

name="$(npm pkg get name --json | jq -r)"

echo "- :package: [**npm**]\
(https://www.npmjs.com/package/$name/v/$CI_VERSION)" \
    >>"$GITHUB_STEP_SUMMARY"

echo ::endgroup::

exit 0
